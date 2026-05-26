import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hello_world/main.dart';

class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      // ListenableBuilder reconstrói a tela inteira quando o carrinho muda
      body: ListenableBuilder(
        listenable: carrinho,
        builder: (context, _) {
          final itens = carrinho.produtosNoCarrinho;

          if (itens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'Seu carrinho está vazio',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.storefront),
                    label: const Text('Ver produtos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Lista de itens ──────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    final produto = itens[index];
                    final qtd = carrinho.quantidade(produto.id);
                    final subtotal = produto.preco * qtd;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Emoji
                            Text(produto.emoji,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 12),

                            // Nome e subtotal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produto.nome,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    'R\$ ${produto.preco.toStringAsFixed(2)} × $qtd'
                                    ' = R\$ ${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Color(0xFF4A7C59),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),

                            // Controles − / qtd / +
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botão remover (lixeira se qtd == 1)
                                _BotaoCircular(
                                  icon: qtd == 1
                                      ? Icons.delete_outline
                                      : Icons.remove,
                                  cor: qtd == 1
                                      ? Colors.red.shade400
                                      : const Color(0xFF4A7C59),
                                  onTap: () => carrinho.remover(produto.id),
                                ),
                                // Quantidade
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '$qtd',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Botão adicionar
                                _BotaoCircular(
                                  icon: Icons.add,
                                  cor: const Color(0xFF4A7C59),
                                  onTap: () => carrinho.adicionar(produto.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Rodapé com total e botão ────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Resumo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${carrinho.totalItens} '
                          '${carrinho.totalItens == 1 ? 'item' : 'itens'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Total: R\$ ${carrinho.totalPreco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Botão finalizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          carrinho.limpar();
                          context.go('/');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Pedido finalizado! Obrigado 🌵'),
                              backgroundColor: Color(0xFF4A7C59),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Finalizar Pedido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Widget auxiliar: botão circular ─────────────────────────────────────────
class _BotaoCircular extends StatelessWidget {
  final IconData icon;
  final Color cor;
  final VoidCallback onTap;

  const _BotaoCircular({
    required this.icon,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cor, width: 1.5),
        ),
        child: Icon(icon, size: 16, color: cor),
      ),
    );
  }
}