import subprocess

# compile  = subprocess.run(['zokrates compile -i main.zok'], stdout=subprocess.PIPE, shell=True, text=True)
# print("compute compile result", compile.stdout)

# constraints  = subprocess.run(['zokrates inspect'], stdout=subprocess.PIPE, shell=True, text=True)
# print(constraints.stdout)

# setup = subprocess.run(['zokrates setup'], stdout=subprocess.PIPE, shell=True, text=True)
# print("compute setup result", setup.stdout)



verifier = subprocess.run(['zokrates export-verifier -o ../../contracts/MVSC.sol'], stdout=subprocess.PIPE, shell=True, text=True)
print("compute witness result", verifier.stdout)

