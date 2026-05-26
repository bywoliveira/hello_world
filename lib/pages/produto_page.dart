import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hello_world/main.dart';

class ProdutoPage extends StatelessWidget {
  final int produtoId;

  const ProdutoPage({super.key, required this.produtoId});

  @override
  Widget build(BuildContext context) {
    final produto = produtos.where((p) => p.id == produtoId).firstOrNull;

    // ── Produto não encontrado ──────────────────────────────────────────────
    if (produto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Não encontrado')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😔', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              const Text('Produto não existe'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Voltar à loja'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Página do produto ───────────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: Text(produto.nome),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          // Ícone do carrinho com badge também aqui
          ListenableBuilder(
            listenable: carrinho,
            builder: (context, _) {
              final total = carrinho.totalItens;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/carrinho'),
                  ),
                  if (total > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: carrinho,
        builder: (context, _) {
          final qtd = carrinho.quantidade(produto.id);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji grande
                Center(
                  child: Text(produto.emoji,
                      style: const TextStyle(fontSize: 100)),
                ),
                const SizedBox(height: 24),

                // Nome e nome científico
                Text(
                  produto.nome,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  produto.nomeCientifico,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Preço unitário
                Text(
                  'R\$ ${produto.preco.toStringAsFixed(2)} / unidade',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF4A7C59),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Descrição
                Text(produto.descricao,
                    style: const TextStyle(fontSize: 15, height: 1.5)),

                const Spacer(),

                // ── Controle de quantidade + botão ──────────────────────
                if (qtd == 0)
                  // Ainda não está no carrinho
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => carrinho.adicionar(produto.id),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Adicionar ao Carrinho'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C59),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                else ...[
                  // Já está no carrinho — mostra controles
                  Center(
                    child: Column(
                      children: [
                        // Contador − / número / +
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BotaoQtd(
                              icon: qtd == 1
                                  ? Icons.delete_outline
                                  : Icons.remove,
                              cor: qtd == 1
                                  ? Colors.red.shade400
                                  : const Color(0xFF4A7C59),
                              onTap: () => carrinho.remover(produto.id),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                '$qtd',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _BotaoQtd(
                              icon: Icons.add,
                              cor: const Color(0xFF4A7C59),
                              onTap: () => carrinho.adicionar(produto.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Subtotal deste produto
                        Text(
                          'Subtotal: R\$ ${(produto.preco * qtd).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A7C59),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botão ir ao carrinho
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/carrinho'),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text('Ver Carrinho  (${carrinho.totalItens} '
                          '${carrinho.totalItens == 1 ? 'item' : 'itens'})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C59),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Widget auxiliar ──────────────────────────────────────────────────────────
class _BotaoQtd extends StatelessWidget {
  final IconData icon;
  final Color cor;
  final VoidCallback onTap;

  const _BotaoQtd({
    required this.icon,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cor, width: 2),
        ),
        child: Icon(icon, size: 20, color: cor),
      ),
    );
  }
}