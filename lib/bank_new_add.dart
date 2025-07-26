import 'package:cheque_manager/models/bank_model.dart';
import 'package:cheque_manager/services/bank_service.dart';
import 'package:cheque_manager/shared/signin_input.dart';
import 'package:flutter/material.dart';
import 'package:cheque_manager/utils/colors.dart';

class AddBankPage extends StatefulWidget {
  const AddBankPage({super.key});

  @override
  State<AddBankPage> createState() => _AddBankPageState();
}

class _AddBankPageState extends State<AddBankPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankService = BankService();

  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final bank = BankModel(
        id: '',
        bankName: _bankNameController.text.trim(),
        accountNumber: int.parse(_accountNumberController.text.trim()),
      );

      try {
        await _bankService.addBank(bank);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Bank added successfully')),
        );

        _formKey.currentState!.reset();
        _bankNameController.clear();
        _accountNumberController.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add New Bank',
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
                heading: 'Bank Name :',
                controller: _bankNameController,
                labelText: 'Enter bank name',
                isPassword: false,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter bank name' : null,
              ),
              const SizedBox(height: 10),
              SignInInput(
                heading: 'Account Number :',
                controller: _accountNumberController,
                labelText: 'Enter account number',
                isPassword: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter account number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
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
                        'Add Bank',
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
