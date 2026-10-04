import argparse, json, os
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import numpy as np
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

MODEL_ID = os.getenv('MODEL_ID', 'Qwen/Qwen2.5-1.5B-Instruct')
VECTOR = os.getenv('STEERING_VECTOR', '')
DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
model = tokenizer = None

def load():
    global model, tokenizer
    tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
    model = AutoModelForCausalLM.from_pretrained(MODEL_ID, torch_dtype='auto', device_map='auto' if DEVICE == 'cuda' else None)
    if DEVICE != 'cuda': model.to(DEVICE)
    model.eval()

def blocks():
    for path in ('model.layers', 'transformer.h', 'gpt_neox.layers'):
        x = model
        try:
            for part in path.split('.'): x = getattr(x, part)
            return x
        except AttributeError: pass
    raise RuntimeError('Architettura non riconosciuta: impossibile individuare i transformer block')

def hidden(text, layer):
    inputs = tokenizer(text, return_tensors='pt').to(model.device)
    with torch.no_grad():
        out = model(**inputs, output_hidden_states=True, use_cache=False)
    hs = out.hidden_states[layer]
    return hs[0, -1].detach().float().cpu()

def make_caa(pos, neg, output, layer):
    if len(pos) != len(neg) or not pos: raise ValueError('positive e negative devono avere lo stesso numero di righe')
    p = torch.stack([hidden(x, layer) for x in pos]); n = torch.stack([hidden(x, layer) for x in neg])
    Path(output).parent.mkdir(parents=True, exist_ok=True); np.save(output, (p.mean(0)-n.mean(0)).numpy())

def generate(prompt, strength=0.0, layer=-1, max_new_tokens=256):
    inputs = tokenizer(prompt, return_tensors='pt').to(model.device)
    hook = None
    if VECTOR and strength:
        vector = torch.tensor(np.load(VECTOR), device=model.device, dtype=model.dtype)
        layer_index = layer if layer >= 0 else len(blocks()) + layer
        def steer(_module, _args, output):
            hidden = output[0] if isinstance(output, tuple) else output
            hidden = hidden + strength * vector.to(hidden.device, hidden.dtype).view(1, 1, -1)
            return (hidden,) + output[1:] if isinstance(output, tuple) else hidden
        hook = blocks()[layer_index].register_forward_hook(steer)
    try:
        with torch.no_grad(): out = model.generate(**inputs, max_new_tokens=max_new_tokens, do_sample=True, temperature=0.7)
    finally:
        if hook: hook.remove()
    return tokenizer.decode(out[0][inputs['input_ids'].shape[1]:], skip_special_tokens=True)

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/generate': self.send_error(404); return
        try:
            body = json.loads(self.rfile.read(int(self.headers.get('content-length', 0))))
            text = generate(body['prompt'], float(body.get('strength', 0)), int(body.get('layer', -1)), int(body.get('max_new_tokens', 256)))
            data = json.dumps({'text': text, 'model': MODEL_ID, 'device': DEVICE}).encode()
            self.send_response(200); self.send_header('Content-Type','application/json'); self.send_header('Access-Control-Allow-Origin','*'); self.end_headers(); self.wfile.write(data)
        except Exception as e: self.send_error(500, str(e))
    def log_message(self, *_): pass

def main():
    p=argparse.ArgumentParser(); sub=p.add_subparsers(dest='cmd'); s=sub.add_parser('serve'); s.add_argument('--port',type=int,default=8787); c=sub.add_parser('make-caa'); c.add_argument('--positive',required=True); c.add_argument('--negative',required=True); c.add_argument('--output',required=True); c.add_argument('--layer',type=int,default=-1); a=p.parse_args()
    if a.cmd=='make-caa':
        load(); make_caa(Path(a.positive).read_text().splitlines(),Path(a.negative).read_text().splitlines(),a.output,a.layer); print('CAA vector saved:',a.output); return
    load(); print('Model:',MODEL_ID,'Device:',DEVICE); ThreadingHTTPServer(('127.0.0.1',a.port),Handler).serve_forever()
if __name__=='__main__': main()
