# Diagnóstico de conectividade — SMAR DF63 (DFI302)

> **Situação:** evidência de campo ainda incompleta. Este registro documenta observações relatadas na bancada, não confirma o IP real do controlador nem a topologia. Não realizar mudanças de rede ou de controle automaticamente.

## Informações coletadas (29/10/2026)

| Item | Observação |
| --- | --- |
| Controlador | SMAR DF63, família DFI302 (identificado pelo operador) |
| IP atribuído ao controlador | `192.168.164.10` (informado pelo operador; **não verificado na rede**) |
| Computador | Windows, adaptador `Ethernet`, `ifIndex 11`, Realtek PCIe GbE |
| Conexão física | Link Ethernet ativo, negociado a 10 Mbps; notebook ligado a tomada/equipamento intermediário |
| IPv4 do notebook | `192.168.164.20/24`, configurado manualmente; estado de endereço deve ser confirmado como `Preferred` |
| Wi-Fi do notebook | `192.168.1.100`, rede separada |
| Ping ao DF63 | `Host de destino inacessível`, respondido pelo próprio `192.168.164.20` |
| ARP na Ethernet | Nenhuma entrada para `192.168.164.10` na consulta feita |
| HTTP/Modbus TCP | Testes iniciais para portas 80/502 falharam via Wi-Fi; não provam estado dos serviços pela Ethernet |

**Importante:** a mensagem `Host de destino inacessível` não representa resposta do DF63, mesmo quando o contador do ping informa 0% de perda. Falta de ARP pode indicar ausência de conectividade L2, VLAN incorreta, porta/cabo errado, endereço do DF63 diferente, ou equipamento desligado. Não é diagnóstico definitivo.

## Sequência de verificação sem interferência no processo

1. Obter autorização do responsável pela planta e conferir no painel as etiquetas de porta, endereço e modelo do controlador. Não desconectar cabos de uma planta em operação.
2. Identificar por documentação ou inspeção qual switch, tomada e VLAN ligam a estação ao DF63. Validar a máscara da rede e a unicidade do IP do notebook com o administrador antes de quaisquer outras alterações.
3. Verificar o estado *local* do adaptador e do IP, sem tocar no controlador:

   ```powershell
   Get-NetAdapter -InterfaceIndex 11 | Format-List Name, Status, LinkSpeed
   Get-NetIPAddress -InterfaceIndex 11 -AddressFamily IPv4 | Format-Table IPAddress,PrefixLength,AddressState,PolicyStore
   Get-NetRoute -InterfaceIndex 11 -AddressFamily IPv4 | Format-Table DestinationPrefix,NextHop,RouteMetric
   arp -a -N 192.168.164.20
   ```

4. Usar a **captura passiva** já documentada em [captura-passiva.md](captura-passiva.md). Selecionar a interface Ethernet correta; manter a planta em operação normal e capturar sem iniciar sessões SYSTEM302/SYSCON, scans, pings ou escrita.
5. Analisar o arquivo localmente com as rotinas documentadas em [automation-plan.md](automation-plan.md), procurando endereços de origem, VLANs, anúncios e protocolos. Ausência de pacotes não comprova falha do controlador em redes com switch.
6. Somente após comprovação de caminho de rede, endereço e protocolo, planejar testes ativos controlados e a integração **somente leitura**, sujeitos a autorização do laboratório.

## Limites

- Não executar download de configuração, reset, escrita de tags, mudanças de setpoint ou descoberta ativa automática.
- Não modificar o IP do DF63, VLANs do switch, interfaces Windows ou rotas pelo aplicativo.
- Não publicar PCAP/PCAPNG, credenciais ou dados de processo no repositório público.
- O PlantaFieldbus permanece em **simulação local** até os gates de validação descritos no README e no plano de automação.

## Pendências para validar em campo

- [ ] Endereço IPv4 efetivo e máscara do DF63 confirmados no equipamento/documentação
- [ ] Mapeamento tomada → switch → VLAN → porta do DF63
- [ ] IP do notebook confirmado `Preferred` e sem duplicidade
- [ ] Captura passiva realizada na interface Ethernet correta
- [ ] Protocolo real observado ou documentado
- [ ] Autorização explícita para qualquer teste ativo
