import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:ckgoat/pages/SellAnimal/SecondaryInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PrimaryInfoPage extends StatefulWidget {
  const PrimaryInfoPage({super.key});

  @override
  _PrimaryInfoPageState createState() => _PrimaryInfoPageState();
}

class _PrimaryInfoPageState extends State<PrimaryInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _breedController = TextEditingController();
  final _ageYearController = TextEditingController(text: "0");
  final _ageMonthController = TextEditingController(text: "0");
  final _weightController =
      TextEditingController(text: "5.0"); // Default to 5.0 kg
  final _priceController = TextEditingController();
  bool _isKg = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Primary Information",
            style: GoogleFonts.archivoBlack(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Breed",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter breed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Age",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Years",
                          style: TextStyle(fontSize: 14),
                        ),
                        IgnorePointer(
                          child: Icon(
                            Icons.arrow_drop_up_outlined,
                            color: Colors.deepOrange.shade400,
                            size: 24,
                          ),
                        ),
                        CupertinoPicker(
                          itemExtent: 50.0,
                          onSelectedItemChanged: (int index) {
                            _ageYearController.text = (index).toString();
                          },
                          children: List<Widget>.generate(20, (int index) {
                            return Center(
                              child: Text('$index'),
                            );
                          }),
                        ),
                        IgnorePointer(
                          child: Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.deepOrange.shade400,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Months",
                          style: TextStyle(fontSize: 14),
                        ),
                        IgnorePointer(
                          child: Icon(
                            Icons.arrow_drop_up_outlined,
                            color: Colors.deepOrange.shade400,
                            size: 24,
                          ),
                        ),
                        CupertinoPicker(
                          itemExtent: 50.0,
                          onSelectedItemChanged: (int index) {
                            _ageMonthController.text = (index).toString();
                          },
                          children: List<Widget>.generate(12, (int index) {
                            return Center(
                              child: Text('$index'),
                            );
                          }),
                        ),
                        IgnorePointer(
                          child: Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.deepOrange.shade400,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Weight",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Switch(
                        value: _isKg,
                        onChanged: (bool value) {
                          setState(() {
                            _isKg = value;
                            _weightController.clear();
                          });
                        },
                        activeColor: Colors.deepOrange,
                      ),
                      Text(_isKg ? "kg" : "g"),
                    ],
                  ),
                ],
              ),
              Center(
                child: Column(
                  children: [
                    IgnorePointer(
                      child: Icon(
                        Icons.arrow_drop_up_outlined,
                        color: Colors.deepOrange.shade400,
                        size: 24,
                      ),
                    ),
                    CupertinoPicker(
                      itemExtent: 50.0,
                      onSelectedItemChanged: (int index) {
                        _weightController.text =
                            _isKg ? '${5 + index}.0' : '${(5 + index) * 100}.0';
                      },
                      children: List<Widget>.generate(
                        _isKg ? 346 : 3460,
                        (int index) {
                          return Center(
                            child: Text(_isKg
                                ? '${5 + index} kg'
                                : '${(5 + index) * 100} g'),
                          );
                        },
                      ),
                    ),
                    IgnorePointer(
                      child: Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Colors.deepOrange.shade400,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Price",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon:
                      Icon(Icons.currency_rupee, color: Colors.deepOrange),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    int years = int.tryParse(_ageYearController.text) ?? 0;
                    int months = int.tryParse(_ageMonthController.text) ?? 0;
                    double weight =
                        double.tryParse(_weightController.text) ?? 5.0;

                    if (_isKg) {
                      weight = weight * 1000; // Convert kg to g
                    }

                    Provider.of<AnimalFormProvider>(context, listen: false)
                        .setPrimaryInfo(
                      _breedController.text,
                      years,
                      months,
                      weight,
                      double.tryParse(_priceController.text) ?? 0.0,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecondaryInfoPage()),
                    );
                  }
                },
                child: const Text('Next',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
