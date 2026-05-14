import 'package:finance_tracker/core/theme_provider.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {
  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
  ];

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);

    final notifier =
        ref.read(expenseProvider.notifier);

    final totalBalance =
        ref.read(expenseProvider.notifier)
            .getTotalBalance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),

        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(themeProvider.notifier)
                  .toggleTheme();
            },

            icon: const Icon(Icons.dark_mode),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController =
              TextEditingController();

          final amountController =
              TextEditingController();

          String selectedCategory = 'Food';

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title:
                        const Text('Add Expense'),

                    content: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        TextField(
                          controller:
                              titleController,

                          decoration:
                              const InputDecoration(
                            labelText: 'Title',
                          ),
                        ),

                        TextField(
                          controller:
                              amountController,

                          keyboardType:
                              TextInputType.number,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Amount',
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        DropdownButton<String>(
                          value:
                              selectedCategory,

                          isExpanded: true,

                          items: categories
                              .map(
                                (category) =>
                                    DropdownMenuItem(
                                  value:
                                      category,

                                  child: Text(
                                    category,
                                  ),
                                ),
                              )
                              .toList(),

                          onChanged: (value) {
                            setState(() {
                              selectedCategory =
                                  value!;
                            });
                          },
                        ),
                      ],
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child:
                            const Text('Cancel'),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(
                                expenseProvider
                                    .notifier,
                              )
                              .addExpense(
                                title:
                                    titleController
                                        .text,

                                amount:
                                    double.parse(
                                  amountController
                                      .text,
                                ),

                                category:
                                    selectedCategory,
                              );

                          Navigator.pop(
                            context,
                          );
                        },

                        child: const Text(
                          'Add',
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },

        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,

            margin:
                const EdgeInsets.all(16),

            padding:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.deepPurple,

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Total Balance',

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  '\$${totalBalance.toStringAsFixed(2)}',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: notifier.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'No Expenses Yet',
                        ),
                      )
                    : GridView.builder(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,

                          crossAxisSpacing: 12,

                          mainAxisSpacing: 12,

                          childAspectRatio: 0.8,
                        ),

                        itemCount:
                            expenses.length,

                        itemBuilder:
                            (context, index) {
                          final expense =
                              expenses[index];

                          return Container(
                            padding:
                                const EdgeInsets.all(
                              16,
                            ),

                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .deepPurple
                                  .withOpacity(
                                    0.2,
                                  ),

                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  expense.title,

                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                Text(
                                  expense.category,
                                ),

                                const Spacer(),

                                Text(
                                  '\$${expense.amount}',

                                  style:
                                      const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,

                                  children: [
                                    IconButton(
                                      onPressed:
                                          () {
                                        final titleController =
                                            TextEditingController(
                                          text:
                                              expense
                                                  .title,
                                        );

                                        final amountController =
                                            TextEditingController(
                                          text: expense
                                              .amount
                                              .toString(),
                                        );

                                        String selectedCategory =
                                            expense
                                                .category;

                                        showDialog(
                                          context:
                                              context,

                                          builder:
                                              (
                                            context,
                                          ) {
                                            return StatefulBuilder(
                                              builder:
                                                  (
                                                context,
                                                setState,
                                              ) {
                                                return AlertDialog(
                                                  title:
                                                      const Text(
                                                    'Edit Expense',
                                                  ),

                                                  content:
                                                      Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,

                                                    children: [
                                                      TextField(
                                                        controller:
                                                            titleController,

                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Title',
                                                        ),
                                                      ),

                                                      TextField(
                                                        controller:
                                                            amountController,

                                                        keyboardType:
                                                            TextInputType.number,

                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Amount',
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height:
                                                            16,
                                                      ),

                                                      DropdownButton<String>(
                                                        value:
                                                            selectedCategory,

                                                        isExpanded:
                                                            true,

                                                        items: categories
                                                            .map(
                                                              (
                                                                category,
                                                              ) =>
                                                                  DropdownMenuItem(
                                                                value:
                                                                    category,

                                                                child:
                                                                    Text(
                                                                  category,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),

                                                        onChanged:
                                                            (
                                                          value,
                                                        ) {
                                                          setState(
                                                            () {
                                                              selectedCategory =
                                                                  value!;
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),

                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () {
                                                        Navigator.pop(
                                                          context,
                                                        );
                                                      },

                                                      child:
                                                          const Text(
                                                        'Cancel',
                                                      ),
                                                    ),

                                                    ElevatedButton(
                                                      onPressed:
                                                          () async {
                                                        await ref
                                                            .read(
                                                              expenseProvider.notifier,
                                                            )
                                                            .updateExpense(
                                                              id:
                                                                  expense.id,

                                                              title:
                                                                  titleController.text,

                                                              amount:
                                                                  double.parse(
                                                                amountController.text,
                                                              ),

                                                              category:
                                                                  selectedCategory,
                                                            );

                                                        Navigator.pop(
                                                          context,
                                                        );
                                                      },

                                                      child:
                                                          const Text(
                                                        'Save',
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },

                                      icon: const Icon(
                                        Icons.edit,
                                        color:
                                            Colors.blue,
                                      ),
                                    ),

                                    IconButton(
                                      onPressed:
                                          () async {
                                        await ref
                                            .read(
                                              expenseProvider
                                                  .notifier,
                                            )
                                            .deleteExpense(
                                              expense.id,
                                            );
                                      },

                                      icon: const Icon(
                                        Icons.delete,
                                        color:
                                            Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}