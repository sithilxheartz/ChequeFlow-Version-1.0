import 'package:cheque_manager/services/bank_service.dart';
import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cheque_manager/services/cheque_service.dart';
import 'package:cheque_manager/shared/signin_input.dart';
import 'package:cheque_manager/services/supplier_service.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddChequePage extends StatefulWidget {
  const AddChequePage({super.key});

  @override
  State<AddChequePage> createState() => _AddChequePageState();
}

class _AddChequePageState extends State<AddChequePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _chequeNumberController = TextEditingController();
  final TextEditingController _grnNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;

  List<String> _supplierNames = [];
  List<String> _bankNames = [];
  String? _selectedSupplier;
  String? _selectedBank;

  bool _isLoading = false;
  final ChequeService _chequeService = ChequeService();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final suppliers = await SupplierService().fetchSuppliers();
    final banks = await BankService().fetchBanks();
    setState(() {
      _supplierNames = suppliers.map((s) => s.supplierName).toList();
      _bankNames = banks.map((b) => b.bankName).toList();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedSupplier == null ||
        _selectedBank == null)
      return;

    setState(() => _isLoading = true);

    final cheque = ChequeModel(
      chequeNumber: int.parse(_chequeNumberController.text.trim()),
      grnNumber: int.parse(_grnNumberController.text.trim()),
      supplierName: _selectedSupplier!,
      bankName: _selectedBank!,
      amount: int.parse(_amountController.text.trim()),
      date: _selectedDate!,
    );

    try {
      await _chequeService.addCheque(cheque);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cheque added successfully')),
      );
      _formKey.currentState!.reset();
      _chequeNumberController.clear();
      _grnNumberController.clear();
      _amountController.clear();
      setState(() {
        _selectedSupplier = null;
        _selectedBank = null;
        _selectedDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 13.0,
        horizontal: 12.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Add New Cheque",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SignInInput(
                heading: 'Cheque Number :',
                controller: _chequeNumberController,
                labelText: 'Enter cheque number',
                isPassword: false,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter cheque number' : null,
              ),
              SignInInput(
                heading: 'GRN Number :',
                controller: _grnNumberController,
                labelText: 'Enter GRN number',
                isPassword: false,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter GRN number' : null,
              ),
              SignInInput(
                heading: 'Amount :',
                controller: _amountController,
                labelText: 'Enter amount',
                isPassword: false,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 10),

              /// Supplier Dropdown with Search
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(labelText: "Search supplier"),
                  ),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: _dropdownDecoration(
                    "Supplier Name",
                  ),
                ),
                asyncItems: (String filter) async {
                  if (filter.isEmpty) return _supplierNames;
                  return await SupplierService().searchSuppliersByName(filter);
                },
                selectedItem: _selectedSupplier,
                onChanged: (val) => setState(() => _selectedSupplier = val),
                validator: (val) => val == null ? "Select a supplier" : null,
              ),

              const SizedBox(height: 20),

              /// Bank Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBank,
                items: _bankNames
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedBank = val),
                decoration: _dropdownDecoration("Bank Name"),
                validator: (val) => val == null ? "Select a bank" : null,
              ),

              const SizedBox(height: 20),

              /// Date Picker
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  _selectedDate == null
                      ? 'Select Cheque Date :'
                      : 'Date: ${DateFormat.yMMMMd().format(_selectedDate!)}',
                  //style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Save Cheque',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
