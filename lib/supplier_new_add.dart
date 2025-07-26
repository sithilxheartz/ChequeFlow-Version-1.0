import 'package:cheque_manager/models/supplier_model.dart';
import 'package:cheque_manager/services/supplier_service.dart';
import 'package:flutter/material.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:cheque_manager/shared/signin_input.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierService = SupplierService();

  final _nameController = TextEditingController();
  final _creditPeriodController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final supplier = SupplierModel(
        id: '',
        supplierName: _nameController.text.trim(),
        creditPeriod: int.parse(_creditPeriodController.text.trim()),
        mobileNumber: _mobileController.text.trim(),
      );

      try {
        await _supplierService.addSupplier(supplier);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Supplier added successfully')),
        );

        _formKey.currentState!.reset();
        _nameController.clear();
        _creditPeriodController.clear();
        _mobileController.clear();
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
    _nameController.dispose();
    _creditPeriodController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add New Supplier',
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
                heading: 'Supplier Name :',
                controller: _nameController,
                labelText: 'Enter supplier name',
                isPassword: false,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),
              SignInInput(
                heading: 'Credit Period (in Days) :',
                controller: _creditPeriodController,
                labelText: 'Enter credit period',
                isPassword: false,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter period';
                  final number = int.tryParse(value);
                  if (number == null || number < 0) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SignInInput(
                heading: 'Mobile Number :',
                controller: _mobileController,
                labelText: 'Enter mobile number',
                isPassword: false,
                validator: (value) => value == null || value.length < 10
                    ? 'Enter valid number'
                    : null,
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
                        'Add Supplier',
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
