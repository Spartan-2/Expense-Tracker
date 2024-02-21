import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBhT-mEz6dz-g9cnmYHHOKZBIg9lOZ4vTM",
          appId: "1:1056856116022:web:db420750ddea41cec24197",
          messagingSenderId: "1056856116022",
          projectId: "expensetrackr-9e42d"));
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<Category, List<Expense>> categorizedExpenses = {
    Category.food: [],
    Category.transportation: [],
    Category.entertainment: [],
    Category.other: [],
  };

  void _addExpense(Expense newExpense) {
    setState(() {
      categorizedExpenses[newExpense.category]?.add(newExpense);
    });
  }

  void _deleteExpense(int index, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  categorizedExpenses[category]?.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  double get totalExpenses {
    return categorizedExpenses.values
        .expand((categoryExpenses) => categoryExpenses)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Tracker')),
      drawer: buildUserDrawer(context),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.yellow,
            child: Center(
              child: Text(
                'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categorizedExpenses.length,
              itemBuilder: (context, categoryIndex) {
                final category = Category.values[categoryIndex];
                final categoryExpenses = categorizedExpenses[category] ?? [];

                return ExpansionTile(
                  title: Text(
                    category.toString().split('.').last,
                    style: TextStyle(fontSize: 18),
                  ),
                  children: categoryExpenses.map((expense) {
                    return ListTile(
                      title: Center(
                        child: Text(
                          expense.title,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      subtitle: Center(
                        child: Text(
                          '${DateFormat.yMMMd().format(expense.date)} - \$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpense(
                              categoryExpenses.indexOf(expense), category);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddExpensesScreen(_addExpense)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildUserDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Kartik Hegde'),
            accountEmail: Text('sampleemail@gmail.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/profile_picture.jpg'),
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
          ),
          ListTile(
            leading:
                Icon(Icons.home, color: Colors.black), // Add an icon for Item 1
            title: Text(
              'Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              // Add your custom logic for Item 1
            },
          ),
          ListTile(
            leading: Icon(Icons.settings,
                color: Colors.black), // Add an icon for Item 2
            title: Text(
              'Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              // Add your custom logic for Item 2
            },
          ),
          // Add more list items with icons here
          ListTile(
            leading: Icon(Icons.star,
                color: Colors.black), // Example: Add an icon for Item 3
            title: Text(
              'Meet Developers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              // Add your custom logic for Item 3
            },
          ),
          // Add more list items as needed
        ],
      ),
    );
  }
}

class AddExpensesScreen extends StatefulWidget {
  final void Function(Expense expense) addExpense;

  AddExpensesScreen(this.addExpense);

  @override
  _AddExpensesScreenState createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.other;

  void _saveExpense() {
    final newExpense = Expense(
      title: _nameController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate!,
      category: _selectedCategory,
    );

    widget.addExpense(newExpense);
    Navigator.pop(context);

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense saved successfully!'),
      ),
    );
  }

  void _selectDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 336)),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _selectedDate = value;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Expense Name',
                alignLabelWithHint: true,
              ),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                alignLabelWithHint: true,
              ),
            ),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Selected Date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
            ),
            DropdownButton<Category>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: Category.values.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.toString().split('.').last),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text(
                'Save Expense',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Category {
  food,
  transportation,
  entertainment,
  other,
}

class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
