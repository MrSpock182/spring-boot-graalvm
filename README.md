# spring-boot-graalvm

## SDK
Para instalar o SDK da graalvm você pode utiliar o SDKMAN, para instalar use o comando
  
  $ curl -s "https://get.sdkman.io" | bash
  $ source "$HOME/.sdkman/bin/sdkman-init.sh"

Estou utilizando o graalvm na versão 20.2.0, para instalar 

  $ sdk install java 20.2.0.r11-grl
  
Vamos instalar também a native-image para gerar uma imagem do nosso projeto

  $ gu install native-image

Para verificar se foi instalado corretamente, verifique a versão da native-image

  $ native-image --version

## Executando o projeto
Após configurar o SDK da graalvm na sua IDE execute o comando para limpar a pasta target do projeto
  
  mvn clean
  
Feita a limpeza da nossa pasta, vamos executar nosso arquivo sh que irá criar a imagem do nosso projeto

  $ bash ./compile.sh
  
Ao finalizar, nossa imagem vai estar dentro da pasta targer/native-image, agora basta executar a imagem para a aplicação subir.

  $ ./target/native-image/{nome_da_imagem}
  
Pronto, já temos nossa aplicação Spring rodando com a Graalvm, 
vale lembrar que essa ainda não é a versão final do Spring para o uso da Graalvm, então muita coisa pode mudar. =)
  
