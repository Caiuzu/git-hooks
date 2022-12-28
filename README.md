# GIT-HOOKS: Como configurar?


## > prepare-commit-msg

---

Para configurar um githook simples que verifica se existe um dos prefixos listados na mensagem de commit, e se o commit não é vazio, você pode usar o githook prepare-commit-msg. Esse githook é acionado antes de o usuário digitar a mensagem de commit, então você pode verificar se a mensagem de commit começa com um dos prefixos listados e, se ela não começar, exibir uma mensagem de erro e cancelar o commit.

- Prefixos:

    ```
    ['build','chore','ci','docs','feat','fix','perf','refactor','revert','style','test']
    ```

- Exemplo de mensagem vazia:

    ```
        "feat:" //falha
        "feat: meu primeiro commit" //correto
    ```

Para adicionar o githook `prepare-commit-msg`, basta criar um arquivo chamado `prepare-commit-msg` na pasta `.git/hooks` do seu projeto. O conteúdo desse arquivo deve ser um script que verifique se a mensagem de commit começa com um dos prefixos listados. Se o tamanho da mensagem for igual ou menor do que o tamanho do prefixo mais o caractere ':', significa que a mensagem de commit está vazia. Você pode usar o seguinte código como base:


```sh

#!/bin/sh

PREFIXES="build chore ci docs feat fix perf refactor revert style test"

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

found=false
for prefix in $PREFIXES; do
  if echo "$commit_msg" | grep "^$prefix" > /dev/null; then
    found=true
    break
  fi
done

if ! $found; then
  echo "A mensagem de commit deve começar com um dos seguintes prefixos: $PREFIXES" >&2
  exit 1
fi

# Verifica se a mensagem de commit não está vazia além do prefixo
if [ ${#commit_msg} -le ${#prefix} + 1 ]; then
  echo "A mensagem de commit não pode estar vazia além do prefixo" >&2
  exit 1
fi

```
---


## > pre-push:
---
Para adicionar um passo de build com testes antes de realizar o comando push, basta adicionar esse passo ao githook pre-push. Esse githook é acionado antes de o comando push ser executado, então você pode realizar o build e os testes antes de permitir que o push prosiga. Você pode usar o seguinte código como base:

```sh

#!/bin/sh

# Realiza o build do projeto
./gradlew build

# Verifica o resultado do build
if [ $? -ne 0 ]; then
  echo "Falha no build. O push não pode ser realizado." >&2
  exit 1
fi

# Realiza os testes
./gradlew test

# Verifica o resultado dos testes
if [ $? -ne 0 ]; then
  echo "Falha nos testes. O push não pode ser realizado." >&2
  exit 1
fi


```

---

Lembre-se de tornar o arquivo `prepare-commit-msg` e o arquivo `pre-push` executáveis, adicionando a permissão de execução para o usuário atual. Para isso, você pode usar o comando `chmod +x <arquivo>`.

----
----


# Automatizando a instalação dos scripts

Objetivo: Realizar a automatização da instalação dos script que adicione e instale os arquivos de githooks `prepare-commit-msg` e `pre-push` na pasta de githooks do projeto e dê permissão de execução para o usuário atual.

```sh

#!/bin/bash

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

```

Esse script cria os arquivos de githooks prepare-commit-msg e pre-push na pasta de githooks do projeto, adiciona o código necessário nesses arquivos e dá permissão de execução para o usuário atual.

Para executar esse script, basta salvar o código acima em um arquivo, por exemplo, install-git-hooks.sh, e executá-lo com o seguinte comando:

```
    ./install-git-hooks.sh
```
