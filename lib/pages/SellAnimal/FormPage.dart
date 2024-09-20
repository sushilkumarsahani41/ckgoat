import 'package:ckgoat/pages/SellAnimal/secondaryPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ckgoat/main.dart';

// Breeds Lists
const List<String> cowBreeds = [
  'Gir',
  'Gir Cross',
  'Sahiwal',
  'Sahiwal Cross',
  'Desi',
  'Desi Cross',
  'Holstein Friesian - HF',
  'Holstein Friesian Cross - HF Cross',
  'Jersey',
  'Jersey Cross',
  'American',
  'American Cross',
  'Dogali',
  'Rathi',
  'Rathi Cross',
  'Tharparkar',
  'Tharparkar Cross',
  'Haryanvi',
  'Marwari',
  'Kankrej',
  'Kapila',
  'Ayrshire',
  'Hardhenu',
  'Nagori',
  'Gujarati',
  'Red Sindhi',
  'Red Sindhi Cross',
  'Deoni',
  'Red Dane',
  'Red Dane Cross',
  'Brown Swiss',
  'Sanchori',
  'Malvi',
  'Other'
];

const List<String> buffaloBreeds = [
  'Murrah',
  'Murrah Cross',
  'Haryanvi',
  'Desi',
  'Desi Cross',
  'Kali',
  'Kundi',
  'Kundi Cross',
  'Jaffrabadi',
  'Banni',
  'Kumbhi',
  'Kumbhi Cross',
  'Kunni',
  'Nili Ravi',
  'Bhadawari',
  'Gujarati',
  'Godavari',
  'Surti',
  'Mehsana',
  'Pandharpuri',
  'Nagpuri',
  'Other'
];

const List<String> goatBreeds = [
  'Usmanabadi',
  'Bital',
  'Shirohi',
  'Sojat',
  'Bor',
  'Barbari',
  'Jamnapuri',
  'Sahen',
  'Other'
];

class SellAnimalPage extends StatelessWidget {
  const SellAnimalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('initial_sell_animal'),
          style: GoogleFonts.archivoBlack(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ),
      body: const AnimalTypePage(),
    );
  }
}

class AnimalTypePage extends StatefulWidget {
  const AnimalTypePage({super.key});

  @override
  State<AnimalTypePage> createState() => _AnimalTypePageState();
}

class _AnimalTypePageState extends State<AnimalTypePage> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('initial_select_animal_type')),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimalTypeButton(animal: "Cow", imagePath: 'assets/cow.png'),
              AnimalTypeButton(
                  animal: "Buffalo", imagePath: 'assets/buffalo.png'),
              AnimalTypeButton(animal: "Sheep", imagePath: 'assets/sheep.png'),
              AnimalTypeButton(animal: "Goat", imagePath: 'assets/goat.png'),
              AnimalTypeButton(animal: "Horse", imagePath: 'assets/horse.png'),
              AnimalTypeButton(animal: "Birds", imagePath: 'assets/bird.png'),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimalTypeButton extends StatelessWidget {
  final String animal;
  final String imagePath;

  const AnimalTypeButton({
    super.key,
    required this.animal,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
          side: const BorderSide(color: Colors.deepOrange, width: 1.5),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrimaryInfoPage(animalType: animal),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localizations.translate(animal.toLowerCase()),
                style: const TextStyle(fontSize: 18, color: Colors.deepOrange)),
            Image.asset(imagePath, height: 80),
          ],
        ),
      ),
    );
  }
}

class PrimaryInfoPage extends StatefulWidget {
  final String animalType;

  const PrimaryInfoPage({required this.animalType, super.key});

  @override
  _PrimaryInfoPageState createState() => _PrimaryInfoPageState();
}

class _PrimaryInfoPageState extends State<PrimaryInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _breedController = TextEditingController();
  final _ageYearController = TextEditingController();
  final _ageMonthController = TextEditingController();
  final _weightController = TextEditingController(text: "5.0");
  final _priceController = TextEditingController();
  String? _selectedGender;
  int _selectedLactation = 0;
  int _selectedMilkCapacity = 0;
  bool _isKg = true;

  @override
  void dispose() {
    _breedController.dispose();
    _ageYearController.dispose();
    _ageMonthController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showBreedSelector(BuildContext context, List<String> breeds) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  localizations.translate('initial_breed'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: breeds.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(localizations.translate(breeds[index])),
                      onTap: () {
                        setState(() {
                          _breedController.text = breeds[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final animalType = widget.animalType;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('initial_primary_info'),
          style: GoogleFonts.archivoBlack(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "${localizations.translate('initial_breed')}: ${localizations.translate(animalType.toLowerCase())}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (animalType == 'Cow' ||
                  animalType == 'Buffalo' ||
                  animalType == 'Goat') ...[
                Text(
                  localizations.translate('initial_breed'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _breedController,
                  readOnly: true,
                  onTap: () {
                    List<String> breeds = [];
                    if (animalType == 'Cow') {
                      breeds = cowBreeds;
                    } else if (animalType == 'Buffalo') {
                      breeds = buffaloBreeds;
                    } else if (animalType == 'Goat') {
                      breeds = goatBreeds;
                    }
                    _showBreedSelector(context, breeds);
                  },
                  decoration: InputDecoration(
                    hintText: localizations.translate('initial_breed'),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.deepOrange, width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations
                          .translate('initial_please_select_breed');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              Text(
                localizations.translate('initial_gender'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(localizations.translate('male')),
                      value: 'Male',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(localizations.translate('female')),
                      value: 'Female',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if ((animalType == 'Cow' ||
                      animalType == 'Buffalo' ||
                      animalType == 'Goat') &&
                  _selectedGender == 'Female') ...[
                Text(
                  localizations.translate('initial_lactation_milk_capacity'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            localizations.translate('initial_lactation'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          DropdownButton<int>(
                            value: _selectedLactation,
                            items: List<DropdownMenuItem<int>>.generate(11,
                                (int index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(
                                    '$index ${localizations.translate('initial_times')}'),
                              );
                            }),
                            onChanged: (int? value) {
                              setState(() {
                                _selectedLactation = value ?? 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            localizations.translate('initial_milk_capacity'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          DropdownButton<int>(
                            value: _selectedMilkCapacity,
                            items: List<DropdownMenuItem<int>>.generate(51,
                                (int index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(
                                    '$index ${localizations.translate('initial_liters')}'),
                              );
                            }),
                            onChanged: (int? value) {
                              setState(() {
                                _selectedMilkCapacity = value ?? 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text(
                localizations.translate('initial_age'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageYearController,
                      decoration: InputDecoration(
                        hintText: localizations.translate('initial_years'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ageMonthController,
                      decoration: InputDecoration(
                        hintText: localizations.translate('initial_months'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.translate('initial_weight'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                      Text(_isKg
                          ? localizations.translate('initial_kg')
                          : localizations.translate('initial_g')),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: localizations.translate('initial_weight'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.translate('initial_price'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: localizations.translate('initial_price'),
                  prefixIcon: const Icon(Icons.currency_rupee,
                      color: Colors.deepOrange),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations
                        .translate('initial_please_enter_price');
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

                    if (!_isKg) {
                      weight = weight / 1000; // Convert g to kg
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecondaryInfoPage(
                          animalType: animalType,
                          breed: _breedController.text,
                          age: years * 12 + months,
                          weight: weight,
                          price: double.tryParse(_priceController.text) ?? 0.0,
                          gender: _selectedGender,
                          lactation: _selectedLactation,
                          milkCapacity: _selectedMilkCapacity,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  localizations.translate('initial_next'),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
