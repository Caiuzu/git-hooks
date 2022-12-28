#!/bin/bash

# Verifica se a pasta .git existe
if [ ! -d ".git" ]; then
  echo "Pasta .git não encontrada. Não foi possível instalar os githooks." >&2
  exit 1
fi

# Cria o arquivo prepare-commit-msg
cat > .git/hooks/prepare-commit-msg <<EOF
#!/bin/sh

PREFIXES="build chore ci docs feat fix perf refactor revert style test"

commit_msg_file=$1
commit_msg=$(cat "\$commit_msg_file")

found=false
for prefix in \$PREFIXES; do
  if echo "\$commit_msg" | grep "^\$prefix" > /dev/null; then
    found=true
    break
  fi
done

if ! \$found; then
  echo "A mensagem de commit deve começar com um dos seguintes prefixos: \$PREFIXES" >&2
  exit 1
fi

# Verifica se a mensagem de commit não está vazia além do prefixo
if [ \${#commit_msg} -le \${#prefix} + 1 ]; then
  echo "A mensagem de commit não pode estar vazia além do prefixo" >&2
  exit 1
fi
EOF

# Cria o arquivo pre-push
cat > .git/hooks/pre-push <<EOF
#!/bin/sh

# Realiza o build do projeto
./gradlew build

# Verifica o resultado do build
if [ \$? -ne 0 ]; then
  echo "Falha no build. O push não pode ser realizado." >&2
  exit 1
fi

# Realiza os testes
./gradlew test

# Verifica o resultado dos testes
if [ \$? -ne 0 ]; then
  echo "Falha nos testes. O push não pode ser realizado." >&2
  exit 1
fi
EOF

# Dá permissão de execução para o usuário atual
chmod +x .git/hooks/prepare-commit-msg
chmod +x .git/hooks/pre-push
