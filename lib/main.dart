import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/produto_page.dart';
import 'pages/carrinho_page.dart';

// ─── ESTADO GLOBAL DO CARRINHO ───────────────────────────────────────────────
// Mapa de produtoId → quantidade. Notifica widgets ao mudar.
class CarrinhoController extends ChangeNotifier {
  final Map<int, int> _itens = {}; // { produtoId: quantidade }

  Map<int, int> get itens => Map.unmodifiable(_itens);

  int quantidade(int produtoId) => _itens[produtoId] ?? 0;

  int get totalItens => _itens.values.fold(0, (soma, q) => soma + q);

  double get totalPreco {
    double total = 0;
    for (final entry in _itens.entries) {
      final produto = produtos.where((p) => p.id == entry.key).firstOrNull;
      if (produto != null) total += produto.preco * entry.value;
    }
    return total;
  }

  void adicionar(int produtoId) {
    _itens[produtoId] = (_itens[produtoId] ?? 0) + 1;
    notifyListeners();
  }

  void remover(int produtoId) {
    if (!_itens.containsKey(produtoId)) return;
    if (_itens[produtoId]! <= 1) {
      _itens.remove(produtoId);
    } else {
      _itens[produtoId] = _itens[produtoId]! - 1;
    }
    notifyListeners();
  }

  void removerTodos(int produtoId) {
    _itens.remove(produtoId);
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }

  List<Suculenta> get produtosNoCarrinho =>
      produtos.where((p) => _itens.containsKey(p.id)).toList();
}

// Instância global acessível por todas as páginas
final carrinho = CarrinhoController();

// ─── AUTENTICAÇÃO (simulada) ─────────────────────────────────────────────────
bool usuarioLogado = false;

// ─── GOROUTER ───────────────────────────────────────────────────────────────
final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final tentandoAcessarCarrinho = state.matchedLocation == '/carrinho';
    if (!usuarioLogado && tentandoAcessarCarrinho) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/produto/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return ProdutoPage(produtoId: id);
      },
    ),
    GoRoute(
      path: '/carrinho',
      builder: (context, state) => const CarrinhoPage(),
    ),
  ],
);

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Suculentas & Cia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A7C59)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// ─── MODELO ──────────────────────────────────────────────────────────────────
class Suculenta {
  final int id;
  final String nome;
  final String nomeCientifico;
  final String emoji;
  final double preco;
  final String descricao;

  const Suculenta({
    required this.id,
    required this.nome,
    required this.nomeCientifico,
    required this.emoji,
    required this.preco,
    required this.descricao,
  });
}

// ─── CATÁLOGO ────────────────────────────────────────────────────────────────
const List<Suculenta> produtos = [
  Suculenta(
    id: 1,
    nome: 'Roseta-de-Pedra',
    nomeCientifico: 'Echeveria elegans',
    emoji: '🌸',
    preco: 18.90,
    descricao:
        'Suculenta compacta com folhas em roseta de tom verde-azulado. '
        'Produz flores rosas na primavera e é perfeita para vasos pequenos.',
  ),
  Suculenta(
    id: 2,
    nome: 'Zebrina',
    nomeCientifico: 'Haworthiopsis attenuata',
    emoji: '🦓',
    preco: 24.50,
    descricao:
        'Conhecida pelas listras brancas que lembram a zebra. '
        'Tolera meia-sombra, ideal para ambientes internos com pouca luz direta.',
  ),
  Suculenta(
    id: 3,
    nome: 'Babosa',
    nomeCientifico: 'Aloe vera',
    emoji: '🌿',
    preco: 32.00,
    descricao:
        'Clássica e multifuncional — o gel das folhas alivia queimaduras e hidrata a pele. '
        'Cresce rápido e fica linda em vasos maiores na varanda.',
  ),
  Suculenta(
    id: 4,
    nome: 'Cacto-Ouriço',
    nomeCientifico: 'Echinocactus grusonii',
    emoji: '🌵',
    preco: 15.00,
    descricao:
        'Esférico, robusto e cheio de espinhos dourados. '
        'Praticamente não precisa de rega — aguenta semanas sem água.',
  ),
  Suculenta(
    id: 5,
    nome: 'Língua-de-Sogra',
    nomeCientifico: 'Dracaena trifasciata',
    emoji: '🗡️',
    preco: 27.00,
    descricao:
        'Folhas eretas com bordas amarelas e padrão marmoreado. '
        'Purifica o ar e sobrevive a quase tudo — sol, sombra e esquecimento.',
  ),
  Suculenta(
    id: 6,
    nome: 'Dedos-de-Fada',
    nomeCientifico: 'Pachyphytum oviferum',
    emoji: '💜',
    preco: 21.00,
    descricao:
        'Folhas ovais com tom lilás-prateado e toque aveludado. '
        'Uma das suculentas mais delicadas e fotogênicas do mercado.',
  ),
];

// ─── HOME PAGE ───────────────────────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌵 Suculentas & Cia'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        actions: [
          // Ícone do carrinho com badge de quantidade
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(produto.emoji, style: const TextStyle(fontSize: 36)),
              title: Text(produto.nome),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nomeCientifico,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                ],
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go('/produto/${produto.id}'),
            ),
          );
        },
      ),
    );
  }
}