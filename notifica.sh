#!/bin/bash

### DECLARAÇÃO DAS VARIÁVEIS DA APLICAÇÃO
WEBHOOK_URL="https://discord.com/api/webhooks/1407444877905494177/Qm3JIvdeZGLKjZbolLd1vP8wzRU6KX0kroeC5axqmZ9tVO0ExhPNAn9ExqL5H_JuyS-s"

FALHANDO=$(supervisorctl status | grep -v RUNNING | sed ':a;N;$!ba;s/\n/\\n/g')

ARQUIVO_CONTAGEM="/usr/share/supervisor-script/contagem.txt"

DATE=$(date +'%Y/%m/%d')

ARQUIVO_LOG="/usr/share/supervisor-script/$DATE-log.txt"

CONTAGEM_NOTIFICACAO=$(cat "$ARQUIVO_CONTAGEM")

### FUNÇÕES DE ALTERAÇÃO DE ESTADO DA APLICAÇÃO
ZERAR_CONTAGEM() {
    echo 0 > "$ARQUIVO_CONTAGEM"
}

SOMA_CONTAGEM() {
    echo 1 > "$ARQUIVO_CONTAGEM"
}   

###FUNÇÕES DE LOG DE SUCESSO E DE FALHA
LOG_SUCESSO() {
    echo "$(date +'%Y/%m/%d-%H:%M') - Aplicações funcionando normalmente" >> $ARQUIVO_LOG
}

LOG_FALHANDO() {
    echo "$(date +'%Y/%m/%d-%H:%M') - Aplicações apresentando falha" >> $ARQUIVO_LOG
}

### FUNÇÃO PARA ENVIAR A MENSAGEM AO DISCORD
NOTIFICA_DISCORD() {

  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"$MSG\"}" \
       $WEBHOOK_URL
}

###CRIA ARQUIVO DE LOG CASO NÃO EXISTA. SE JÁ EXISTIR, NÃO FAZ NADA
touch "$ARQUIVO_LOG" 2>/dev/null 

### VERIFICAÇÃO DO GATILHO
#SE ESTIVER FALHANDO E NÃO TIVER SIDO CONTADO, ENVIA NOTIFICAÇÃO E LOGA
if [[ -n "$FALHANDO" && "$CONTAGEM_NOTIFICACAO" -eq 0 ]]; then
    MSG=":rotating_light: **ALERTA**: Supervisor com problemas!\n\`\`\`$FALHANDO\`\`\`"
    NOTIFICA_DISCORD
    SOMA_CONTAGEM
    LOG_FALHANDO
    
#SE ESTIVER FALHANDO E JÁ TIVER CONTADO, NÃO NOTIFICA E LOGA
elif [[ -n "$FALHANDO" && "$CONTAGEM_NOTIFICACAO" -eq 1 ]]; then
    LOG_FALHANDO

#SE NÃO ESTIVER FALHANDO MAS ESTIVER COM CONTAGEM, ZERA A CONTAGEM E NOTIFICA O SUCESSO
elif [[ -z "$FALHANDO" && "$CONTAGEM_NOTIFICACAO" -eq 1 ]]; then
    MSG=":white_check_mark: **INFORMATIVO**: Serviços funcionando normalmente!"
    LOG_SUCESSO
    NOTIFICA_DISCORD
    ZERAR_CONTAGEM

#NÃO TESTA NENHUMA CONDIÇÃO SÓ LOGA QUE ESTÁ FUNCIOANNDO
else 
    LOG_SUCESSO
fi