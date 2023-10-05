import subprocess

result = subprocess.run(['cat ../../codes/output/decryption_output.txt'], stdout=subprocess.PIPE, shell=True, text=True)
input = result.stdout

witness = subprocess.run(['zokrates compute-witness -a ' + input + ' --verbose'], stdout=subprocess.PIPE, shell=True, text=True)
print("compute witness result", witness.stdout)

proof = subprocess.run(['zokrates generate-proof'], stdout=subprocess.PIPE, shell=True, text=True)

print("proof generation result ", proof.stdout)