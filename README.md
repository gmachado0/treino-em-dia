# Treino em Dia — primeira versão

Aplicativo web responsivo para acompanhar a rotina de treino.

## Como usar
- Acesse https://gmachado0.github.io/treino-em-dia/.
- Crie uma conta ou entre com seu e-mail e senha.
- No primeiro acesso, responda ao questionário para gerar seu plano personalizado.
- Os dados da conta são armazenados no Supabase e protegidos por Row Level Security (RLS).
- Use Configurações → Exportar backup para salvar uma cópia JSON adicional.

## Funcionalidades
- Dashboard semanal e marcação de sessões concluídas.
- Fichas de musculação com registro de carga, repetições e séries.
- Cronômetro de descanso de 90 segundos.
- Registro de cardio.
- Histórico de peso e medidas com gráfico.
- Exportação e importação de backup JSON.
- Interface dark responsiva.

## Limitações desta versão
- O plano inicial é gerado por regras a partir das respostas do questionário e da biblioteca de exercícios.
- A conclusão de sessão é um registro manual; o app não substitui orientação profissional.
- A biblioteca de exercícios é mantida no banco de dados.
