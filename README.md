# Processador em Verilog — ISA própria (origem ARM)

Processador uniciclo (com pequenos desvios multiciclo) descrito em Verilog,
alvo FPGA **Intel Cyclone IV E (EP4CE6E22C8)** via **Quartus Prime 20.1.1
Lite**. O ISA começou inspirado no ARM, mas foi evoluindo com instruções
próprias (I/O por UART, contador de instruções/"clock", acesso indireto a
memória) para suportar um projeto de Sistema Operacional que roda sobre ele.
Hoje é uma arquitetura independente.

> Placa-alvo: Cyclone IV E. Pinagem (clock, reset, UART, displays de 7
> segmentos) definida em `processador.qsf`.

## Características

- Palavra de **32 bits**, opcode de **8 bits** (`instr[31:24]`).
- Banco com registradores de 32 bits endereçados por 6 bits (`R0`–`R63`),
  com registradores especiais (ex.: `R63` para retorno de `JAL`, `R56`/`R57`
  usados em cálculo de endereço/PC).
- **ULA** com soma, subtração, divisão, multiplicação, XOR, NOT, comparação
  (gera flags maior/igual/menor) e passagem direta.
- **Memórias** de instrução e de dados separadas (Harvard), 32 bits de largura.
- **I/O serial via UART** (`uart_rx` / `uart_tx` a 5208 ciclos por bit) para as
  instruções `IN`/`OUT`, mais máquinas de estado de handshake.
- **Display de 7 segmentos** (4 dígitos multiplexados) mostrando o PC.
- **Divisor de clock** para rodar a lógica principal em frequência reduzida.
- **Contador de instruções** (`instruction_counter`) que suporta a instrução
  `CLK`, usada como base de tempo / interrupção por estouro no SO.

## Estrutura do projeto

```
.
├── processador.v            # Top-level: liga todos os módulos e muxes
├── Unidade_controle.v       # Decodificador de opcode -> sinais de controle
├── ULA.v                    # Unidade lógico-aritmética
├── Reg_File.v               # Banco de registradores
├── PC.v                     # Program Counter
├── Mem_Instr.v              # Memória de instruções (ROM via $readmemb)
├── Mem_Data.v               # Memória de dados (RAM)
├── extensor.v               # Extensor de imediatos / entrada da UART
├── display_controller.v     # Driver dos displays de 7 segmentos
├── freq_divider.v           # Divisor de frequência do clock
├── instruction_counter.v    # Contador de instruções / base "CLK"
├── uart_rx.v / uart_tx.v    # Transceptor UART
├── uart_state_machine.v     # FSM de transmissão (OUT)
├── rx_ready_sm.v            # FSM de recepção (IN)
├── processador.qpf / .qsf   # Arquivos de projeto do Quartus
└── codigos/                 # Programas em binário carregados na ROM
    ├── so_bin.txt           # Sistema Operacional (0x000)
    ├── area_bin.txt         # (0x300)
    ├── div_bin.txt          # (0x600)
    ├── fat_bin.txt          # (0x900)
    ├── fib_bin.txt          # (0x1200)
    ├── gcd_bin.txt          # (0x1500)
    └── ...                  # mult, pot, soma, sub, etc.
```

A memória de instruções é inicializada em `Mem_Instr.v` com `$readmemb`,
mapeando cada programa de `codigos/` para uma faixa de endereços. O caminho é
**relativo** (`codigos/...`), então mantenha essa pasta junto do projeto ao
compilar.

## Conjunto de instruções (ISA)

Formato geral: `opcode[31:24] | RN[23:18] | RD[17:12] | ... | RM[5:0] | IMM`.

| Opcode (bin) | Dec | Mnemônico  | Descrição                                   |
|--------------|-----|------------|---------------------------------------------|
| `00000000`   | 0   | `add`      | `RD = RN + RM`                              |
| `00000001`   | 1   | `addi`     | `RD = RN + IMM`                             |
| `00000010`   | 2   | `sub`      | `RD = RN - RM`                              |
| `00000011`   | 3   | `subi`     | `RD = RN - IMM`                             |
| `00000100`   | 4   | `cmp`      | compara `RN` e `RM`, resultado em `RD`      |
| `00000101`   | 5   | `cmpi`     | compara `RN` e `IMM`, resultado em `RD`     |
| `00000110`   | 6   | `mov`      | `RD = RM`                                   |
| `00000111`   | 7   | `mult`     | `RD = RN * RM`                              |
| `00001000`   | 8   | `multi`    | `RD = RN * IMM`                             |
| `00001001`   | 9   | `div`      | `RD = RN / RM`                              |
| `00001010`   | 10  | `divi`     | `RD = RN / IMM`                             |
| `00001011`   | 11  | `str`      | memória[`RN`+`IMM`] = `RD`                  |
| `00001100`   | 12  | `ldr`      | `RD = memória[RN+IMM]`                      |
| `00001101`   | 13  | `ldrb`     | carrega imediato em `RD`                    |
| `00001110`   | 14  | `beq`      | desvia se igual                             |
| `00001111`   | 15  | `bnq`      | desvia se diferente                         |
| `00010000`   | 16  | `bgt`      | desvia se maior                             |
| `00010001`   | 17  | `blt`      | desvia se menor                             |
| `00010010`   | 18  | `jmp`      | salto incondicional (imediato)              |
| `00010011`   | 19  | `jal`      | salto com link (retorno em `R63`)           |
| `00010100`   | 20  | `jmpr`     | salto para endereço em registrador          |
| `00010101`   | 21  | `in`       | lê um byte da UART para `RD`                |
| `00010110`   | 22  | `out`      | envia valor pela UART                       |
| `00010111`   | 23  | `posin`    | sincronização de entrada (handshake)        |
| `00011000`   | 24  | `nop`      | sem operação                                |
| `00011001`   | 25  | `halt`     | trava o PC (parada)                         |
| `00011010`   | 26  | `clk`      | arma o contador de instruções (`IMM`)       |
| `00011011`   | 27  | `ldrclk`   | lê o valor do contador em `RD`              |
| `00011100`   | 28  | `strr`     | store indireto (2 ciclos): mem[`RN`+`IMM`] = R[reg] |
| `00011101`   | 29  | `ldrr`     | load indireto (2 ciclos): R[reg] = mem[...] |

`strr` e `ldrr` são multiciclo: a unidade de controle usa uma pequena FSM
(`state_2cycles`) para capturar o índice do registrador em um ciclo e efetuar
o acesso à memória no seguinte. Essas instruções foram adicionadas para dar ao
SO acesso indireto a registradores/memória.

### Resultado da comparação (cmp / cmpi)

`cmp` e `cmpi` gravam o resultado da comparação em `RD`:

- `0` → `RN > RM` / `RN > IMM` (maior)
- `1` → `RN == RM` / `RN == IMM` (igual)
- `2` → `RN < RM` / `RN < IMM` (menor)

Esse valor em `RD` é usado depois pelas instruções de desvio (`beq`, `bnq`,
`bgt`, `blt`), que a unidade de controle lê como flags.

## Como compilar e gravar

Pré-requisitos: **Quartus Prime 20.1.1 Lite** (ou compatível) e a placa
Cyclone IV E.

1. Abra `processador.qpf` no Quartus.
2. Confirme que a pasta `codigos/` está presente (a ROM é carregada dela).
3. Rode a compilação completa (*Processing → Start Compilation*).
4. Programe o FPGA com o `.sof` gerado (*Tools → Programmer*).

Pinos principais (ver `processador.qsf`): `clock` = PIN_23, `reset_btn` =
PIN_88, UART `i_rx` = PIN_143 / `o_tx` = PIN_142, displays em `o_disp[7:0]` e
`o_sel_disp[3:0]`.

## Programas de exemplo (`codigos/`)

Cada `.txt` é um binário (uma instrução de 32 bits por linha) carregado em uma
faixa da ROM. O destaque é `so_bin.txt`, o sistema operacional que motivou as
extensões do ISA. Os demais (`fat`, `fib`, `gcd`, `div`, `area`, etc.) são
rotinas de teste/demonstração.

## Observações sobre o repositório

O `.gitignore` deste projeto versiona apenas o essencial (fontes `.v`, os
arquivos de projeto `.qpf`/`.qsf` e os binários em `codigos/`). Artefatos
gerados pelo Quartus (`db/`, `incremental_db/`, `output_files/`, relatórios,
`.qar`, `.zip`, `.bak`) ficam fora, pois são recriados a cada compilação.
