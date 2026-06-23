import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages_lista/carrinho_page_mercado.dart';

// ─── MODELO DO PRODUTO ────────────────────────────────────────────────────
class Frutinha {
  final int id;
  final String nome;
  final String emoji;
  final double preco;
  final String categoria;

  const Frutinha({
    required this.id,
    required this.nome,
    required this.emoji,
    required this.preco,
    required this.categoria,
  });
}
// Aqui a gente vai definir a classe que vai moldar as frutas no código, eu apelidei ela de frutinhas
// ela vai pega o id, nome, o emoji é só para mostrar a fruta e categoria que vai permitir a separação das frutas
//também tem o preço

// ─── CATÁLOGO ─────────────────────────────────────────────────────────────
const List<Frutinha> produtos = [
  Frutinha(
    id: 1,
    nome: 'laranja',
    emoji: '🍊',
    preco: 5.00,
    categoria: 'Cítricos',
  ),
  Frutinha(
    id: 2,
    nome: 'kiwi',
    emoji: '🥝',
    preco: 8.00,
    categoria: 'Cítricos',
  ),
  Frutinha(
    id: 3,
    nome: 'maçã',
    emoji: '🍎',
    preco: 10.00,
    categoria: 'Clássicos',
  ),
  Frutinha(
    id: 4,
    nome: 'banana',
    emoji: '🍌',
    preco: 7.00,
    categoria: 'Clássicos',
  ),
  Frutinha(
    id: 5,
    nome: 'melancia',
    emoji: '🍉',
    preco: 30.00,
    categoria: 'Doces',
  ),
  Frutinha(
    id: 6,
    nome: 'uva',
    emoji: '🍇',
    preco: 20.00,
    categoria: 'Doces',
  ),
];
//aqui eu comecei definir quais frutas iriam aparecer no catalogo
//de acordo com o que eu tinha definido na classe das frutinhas

// ─── parte do carrinho ─────────────────────────────────────────────────────────────
class ItemCarrinho {
  final Frutinha produto;
  int quantidade;
  ItemCarrinho(this.produto, this.quantidade);
}
//declarou a classe do itemCarrinho que vai ser o item a ir ao carrinho
//determinou o produto e a quantidade

class CarrinhoController extends ChangeNotifier {
  List<ItemCarrinho> itens = [];

  void adicionar(Frutinha produto) {
    for (var item in itens) {
      if (item.produto.id == produto.id) {
        item.quantidade++;
        notifyListeners();
        return;
      }
    }
    itens.add(ItemCarrinho(produto, 1));
    notifyListeners();
  }

  void remover(Frutinha produto) {
    for (int i = 0; i < itens.length; i++) {
      if (itens[i].produto.id == produto.id) {
        if (itens[i].quantidade > 1) {
          itens[i].quantidade--;
        } else {
          itens.removeAt(i);
        }
        notifyListeners();
        return;
      }
    }
  }
  //esse controlador guarda os produtos do carrinho, aumenta 
  //ou diminui suas quantidades e avisa a interface para se atualizar sempre que algo mudar
  // --------------------------------------------------

  void removerItemCompleto(Frutinha produto) {
    itens.removeWhere((item) => item.produto.id == produto.id);
    notifyListeners();
  }

  double get total {
    double soma = 0;
    for (var item in itens) soma += item.produto.preco * item.quantidade;
    return soma;
  }

  int get totalItens {
    int soma = 0;
    for (var item in itens) soma += item.quantidade;
    return soma;
  }

  void limpar() {
    itens.clear();
    notifyListeners();
  }
}

final carrinho = CarrinhoController();

// removerItemCompleto → remove um produto do carrinho.
// total → calcula o preço total.
// totalItens → conta quantos itens existem.
// limpar → esvazia o carrinho.
// carrinho → é o objeto que controla tudo isso.

// ─── ROTAS ────────────────────────────────────────────────────────────────
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/carrinho', builder: (context, state) => const CarrinhoPage()),
  ],
);

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Feira de Frutas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 130, 255, 168)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
// aqui nessa parte ele vai trabalhar com a parte de rotas, que 
// também fala sobre o GoRouter, que é um tipo de navegação, inclusive é 
// por isso que tem uma pasta que vai trabalhar com os dados levados pro carrinho
// essa parte é o papel do goRouter

// ─── pag principal ────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _categoriaSelecionada = 'Todos';

  static const List<String> _categorias = [
    'Todos',
    'Cítricos',
    'Doces',
    'Clássicos',
    'Outros',
  ];

  List<Frutinha> get _produtosFiltrados {
    if (_categoriaSelecionada == 'Todos') return produtos;
    return produtos.where((p) => p.categoria == _categoriaSelecionada).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feira de Frutas'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        actions: [
          ListenableBuilder(
            listenable: carrinho,
            builder: (context, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/carrinho'),
                  ),
                  if (carrinho.totalItens > 0)
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
                          '${carrinho.totalItens}',
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
// essa parte aqui é mais estilização mesmo da página principal
// ------------------------------------------------------------------------------------------------------------------------------

        // ─── parte das categorias ───────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final selecionada = cat == _categoriaSelecionada;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selecionada,
                    onSelected: (_) => setState(() => _categoriaSelecionada = cat),
                    selectedColor: Colors.white,
                    backgroundColor: const Color(0xFF3A6B4A),
                    labelStyle: TextStyle(
                      color: selecionada ? const Color(0xFF4A7C59) : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
        ),
      ),

      // essa parte ela vai mexer com a parte das categorias
      // porque cada produto tem sua própria caracteristica, ent tem uma categoria só para o tipo dele
      // no caso seria semelhante a uma sessão no html

      // ----------------------------------------------------------------------------------------------------------------

      // ─── lista dos produtos ────────────────────────────────────────────
      body: _produtosFiltrados.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto nesta categoria.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = _produtosFiltrados[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(produto.emoji, style: const TextStyle(fontSize: 36)),
                    title: Text(produto.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.nome,
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
                    trailing: IconButton(
                      icon: const Icon(Icons.add,
                          color: Color(0xFF4A7C59)),
                      onPressed: () {
                        carrinho.adicionar(produto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${produto.nome} adicionado!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // Se houver produtos, eles são exibidos em uma lista com
            // um botão para adicioná-los ao carrinho, se não, é mostrada uma mensagem
            // dizendo que não há produtos nessa categoria
    //  -------------------------------------------------------------------------------------------------------------------------
      // ─── parte do menu inferior ──────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {}, // sem funcionalidade
        selectedItemColor: const Color(0xFF4A7C59),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}