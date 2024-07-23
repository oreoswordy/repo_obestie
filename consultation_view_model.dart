import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hallobet/model/obesity.dart';
import 'package:hallobet/utils/apps_color.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:csv/csv.dart';

import '../model/consultation.dart';

class ConsultationViewModel extends ChangeNotifier {
  TextEditingController jenisKelaminController = TextEditingController();
  TextEditingController usiaController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController frequnceVegetable = TextEditingController();
  TextEditingController frequnceEat = TextEditingController();
  TextEditingController frequnceDrink = TextEditingController();
  TextEditingController frequnceActivity = TextEditingController();
  TextEditingController frequnceUseTech = TextEditingController();
  TextEditingController pickOptionController = TextEditingController();
  TextEditingController snackController = TextEditingController();
  TextEditingController obesityController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController cigaretteController = TextEditingController();
  TextEditingController countingCaloriesController = TextEditingController();
  TextEditingController transportationController = TextEditingController();
  TextEditingController alcoholController = TextEditingController();

  PickOption? selectedPickOption;
  PickOption1? selectedVegetable;
  PickOption2? selectedEat;
  PickOption? selectedSnack;
  PickOption1? selectedDrink;
  PickOption? selectedActivity;
  PickOption3? selectedUseTech;
  PickOption? selectedAlcohol;

  PickOptionYesNo? selectedObecity;
  PickOptionYesNo? selectedCalories;
  PickOptionYesNo? selectedCigarette;
  PickOptionYesNo? selectedCountingCalories;

  PickOptionTransportation? selectedTransportation;

  PickOptionGender? selectedGender;

  NumberFrequence? selectedNumberFrequenceEat;
  NumberFrequence? selectedNumberFrequenceDrink;
  NumberFrequence? selectedNumberFrequenceActivity;
  NumberFrequence? selectedNumberFrequenceUseTech;

  String _predictionResult = 'Tidak Diketahui';
  String get predictionResult => _predictionResult;

  List<Obesity> dataset = [];
  KnnClassifier? _classifier;

  int k = 4; 
  
  // Nilai k untuk KNN
  // Method to convert categorical values to numeric
  double convertCategoricalValue(String category, Map<String, double> map) {
    return map[category] ?? 0.0;
  }

  // Map categorical values to numbers
  final Map<String, double> genderMap = {'Male': 1.0, 'Female': 0.0};
  final Map<String, double> yesNoMap = {'Yes': 1.0, 'No': 0.0};
  final Map<String, double> frequencyMap = {
    'Never': 0.0,
    'Sometimes': 1.0,
    'Frequently': 2.0,
    'Always': 3.0
  };
  final Map<String, double> transportationMap = {
    'Walking': 0.0,
    'Automobile': 1.0,
    'Motorbike': 2.0,
    'Public_Transportation': 3.0,
    'Bike': 4.0
  };

  List<DropdownMenuItem<OptionCategory>> get optionItems {
    return OptionCategory.values.map((choice) {
      return DropdownMenuItem<OptionCategory>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<TKSS>> get tkssItems {
    return TKSS.values.map((choice) {
      return DropdownMenuItem<TKSS>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<KSS>> get kssItems {
    return KSS.values.map((choice) {
      return DropdownMenuItem<KSS>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<TKS>> get tksItems {
    return TKS.values.map((choice) {
      return DropdownMenuItem<TKS>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setFrequenceVegetable(PickOption1? value) {
    selectedVegetable = value;
    frequnceVegetable.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<NumberFrequence>> get numberFrequenceVegetableItems {
    return NumberFrequence.values.map((choice) {
      return DropdownMenuItem<NumberFrequence>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setFrequnceEat(NumberFrequence? value) {
    selectedNumberFrequenceEat = value;
    frequnceEat.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<NumberFrequence>> get numberFrequenceEatItems {
    return NumberFrequence.values.map((choice) {
      return DropdownMenuItem<NumberFrequence>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setFrequnceDrink(NumberFrequence? value) {
    selectedNumberFrequenceDrink = value;
    frequnceDrink.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<NumberFrequence>> get numberFrequenceDrinkItems {
    return NumberFrequence.values.map((choice) {
      return DropdownMenuItem<NumberFrequence>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setFrequnceActivity(NumberFrequence? value) {
    selectedNumberFrequenceActivity = value;
    frequnceActivity.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<NumberFrequence>> get numberFrequenceActivityItems {
    return NumberFrequence.values.map((choice) {
      return DropdownMenuItem<NumberFrequence>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setFrequnceUseTech(NumberFrequence? value) {
    selectedNumberFrequenceUseTech = value;
    frequnceUseTech.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<NumberFrequence>> get numberFrequenceUseTechItems {
    return NumberFrequence.values.map((choice) {
      return DropdownMenuItem<NumberFrequence>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<PickOption>> get numberPickOptionItems {
    return PickOption.values.map((choice) {
      return DropdownMenuItem<PickOption>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<PickOption1>> get numberPickOptionItems1 {
    return PickOption1.values.map((choice) {
      return DropdownMenuItem<PickOption1>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<PickOption2>> get numberPickOptionItems2 {
    return PickOption2.values.map((choice) {
      return DropdownMenuItem<PickOption2>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<PickOption3>> get numberPickOptionItems3 {
    return PickOption3.values.map((choice) {
      return DropdownMenuItem<PickOption3>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  List<DropdownMenuItem<PickOptionNol>> get numberPickOptionItemsNol {
    return PickOptionNol.values.map((choice) {
      return DropdownMenuItem<PickOptionNol>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setPickOption(PickOption? value) {
    selectedPickOption = value;
    pickOptionController.text = value?.label ?? "";
    notifyListeners();
  }

  void setVegetable(PickOption1? value) {
    selectedVegetable = value;
    frequnceVegetable.text = value?.label ?? "";
    notifyListeners();
  }

  void setEat(PickOption2? value) {
    selectedEat = value;
    notifyListeners();
  }

  void setSnack(PickOption? value) {
    selectedSnack = value;
    snackController.text = value?.label ?? "";
    notifyListeners();
  }

  void setDrink(PickOption1? value) {
    selectedDrink = value;
    frequnceDrink.text = value?.label ?? "";
    notifyListeners();
  }

  void setActivity(PickOption? value) {
    selectedActivity = value;
    frequnceActivity.text = value?.label ?? "";
    notifyListeners();
  }

  void setUseTech(PickOption3? value) {
    selectedUseTech = value;
    frequnceUseTech.text = value?.label ?? "";
    notifyListeners();
  }

  void setAlcohol(PickOption? value) {
    selectedAlcohol = value;
    alcoholController.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<PickOptionYesNo>> get yesnoItems {
    return PickOptionYesNo.values.map((choice) {
      return DropdownMenuItem<PickOptionYesNo>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setObecity(PickOptionYesNo? value) {
    selectedObecity = value;
    obesityController.text = value?.label ?? "";
    print(selectedObecity?.value);
    notifyListeners();
  }

  void setCalories(PickOptionYesNo? value) {
    selectedCalories = value;
    caloriesController.text = value?.label ?? "";
    print(selectedCalories?.value);
    notifyListeners();
  }

  void setCigarette(PickOptionYesNo? value) {
    selectedCigarette = value;
    cigaretteController.text = value?.label ?? "";
    print(selectedCalories?.value);
    notifyListeners();
  }

  void setCountingCalories(PickOptionYesNo? value) {
    selectedCountingCalories = value;
    countingCaloriesController.text = value?.label ?? "";
    notifyListeners();
  }

  List<DropdownMenuItem<PickOptionTransportation>> get transportationItems {
    return PickOptionTransportation.values.map((choice) {
      return DropdownMenuItem<PickOptionTransportation>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setTransportation(PickOptionTransportation? value) {
    selectedTransportation = value;
    transportationController.text = value?.label ?? "";
    print(selectedTransportation?.value);
    notifyListeners();
  }

  List<DropdownMenuItem<PickOptionGender>> get genderItems {
    return PickOptionGender.values.map((choice) {
      return DropdownMenuItem<PickOptionGender>(
        value: choice,
        child: Text(choice.label),
      );
    }).toList();
  }

  void setGender(PickOptionGender? value) {
    selectedGender = value;
    jenisKelaminController.text = value?.label ?? "";
    print(selectedGender?.value);
    notifyListeners();
  }

  void reset() {
    selectedGender = null;
    selectedObecity = null;
    selectedCalories = null;
    selectedCigarette = null;
    selectedCountingCalories = null;
    selectedVegetable = null;
    selectedEat = null;
    selectedSnack = null;
    selectedActivity = null;
    selectedDrink = null;
    selectedUseTech = null;
    selectedAlcohol = null;
    selectedTransportation = null;
    notifyListeners();
  }

  // ========== submit ==========
  void submit(BuildContext context) async {
    // Check if any data is empty
    if (selectedGender == null ||
        usiaController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty ||
        selectedObecity == null ||
        selectedCalories == null ||
        selectedVegetable == null ||
        selectedEat == null ||
        selectedSnack == null ||
        selectedCigarette == null ||
        selectedDrink == null ||
        selectedCountingCalories == null ||
        selectedActivity == null ||
        selectedUseTech == null ||
        selectedAlcohol == null ||
        selectedTransportation == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Data Belum Diisi'),
            content: Text('Mohon lengkapi semua data sebelum konsultasi.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final _rawData = await rootBundle.loadString("assets/obesity_dataset.csv");
    List<List<dynamic>> _listData =
        const CsvToListConverter().convert(_rawData);

    final samples = DataFrame.fromRawCsv(_rawData, headerExists: true);
    final targetName = 'NObeyesdad';

    final features = DataFrame.fromSeries([
      Series('genders', [selectedGender?.value]),
      Series('age', [usiaController.text]),
      Series('height', [heightController.text]),
      Series('weight', [weightController.text]),
      Series('familyHistoryWithOverweight', [selectedObecity?.value]),
      Series('favc', [selectedCalories?.value]),
      Series('fcvc', [selectedVegetable?.value]),
      Series('ncp', [selectedEat?.value]),
      Series('caec', [selectedSnack?.value]),
      Series('smoke', [selectedCigarette?.value]),
      Series('ch2o', [selectedDrink?.value]),
      Series('scc', [selectedCountingCalories?.value]),
      Series('faf', [selectedActivity?.value]),
      Series('tue', [selectedUseTech?.value]),
      Series('calc', [selectedAlcohol?.value]),
      Series('mtrans', [selectedTransportation?.value]),
    ]);

    // Perform prediction and calculations
    print('===================');
    print(' Hitung Euclidean');

    final genderValue = selectedGender?.value ?? 0;
    final usia = int.parse(usiaController.text);
    final tinggiValue = int.parse(heightController.text);
    final tinggi = tinggiValue / 100;
    final berat = int.parse(weightController.text);

    final obesitasValue = selectedObecity?.value ?? 0;
    final kaloriValue = selectedCalories?.value ?? 0;
    final sayurValue = selectedVegetable?.value ?? 0;
    final makanValue = selectedEat?.value ?? 0;
    final snackValue = selectedSnack?.value ?? 0;
    final rokokValue = selectedCigarette?.value ?? 0;
    final minumValue = selectedDrink?.value ?? 0;
    final menghitungKaloriValue = selectedCountingCalories?.value ?? 0;
    final aktivitasValue = selectedActivity?.value ?? 0;
    final teknologiValue = selectedUseTech?.value ?? 0;
    final alkoholValue = selectedAlcohol?.value ?? 0;
    final transportasiValue = selectedTransportation?.value ?? 0;

    List<double> euclidean = [];
    List<Map<String, dynamic>> HasilAkhir = [];

    print('=================================');
    print(' Penyesuaian nilai Dataset');
    print('=================================');

    for (int i = 0; i < 2110; i++) {
      final dataRow = samples.rows.elementAt(i).toList();
      final csvGenderValue = dataRow[0] as num;
      final csvUsiaValue = dataRow[1] as num;
      final csvTinggiValue = dataRow[2] as num;
      final csvBeratValue = dataRow[3] as num;
      final csvObesitasValue = dataRow[4] as num;
      final csvKaloriValue = dataRow[5] as num;
      final csvSayurValue = dataRow[6] as num;
      final csvMakanValue = dataRow[7] as num;
      final csvSnackValue = dataRow[8] as num;
      final csvRokokValue = dataRow[9] as num;
      final csvMinumValue = dataRow[10] as num;
      final csvMenghitungKaloriValue = dataRow[11] as num;
      final csvAktivitasValue = dataRow[12] as num;
      final csvTeknologiValue = dataRow[13] as num;
      final csvAlkoholValue = dataRow[14] as num;
      final csvTransportasiValue = dataRow[15] as num;
      final csvDiagnosis = dataRow[16] as String;

      final hitung = pow(genderValue - csvGenderValue, 2) +
          pow(usia - csvUsiaValue, 2) +
          pow(tinggi - csvTinggiValue, 2) +
          pow(berat - csvBeratValue, 2) +
          pow(obesitasValue - csvObesitasValue, 2) +
          pow(kaloriValue - csvKaloriValue, 2) +
          pow(sayurValue - csvSayurValue, 2) +
          pow(makanValue - csvMakanValue, 2) +
          pow(snackValue - csvSnackValue, 2) +
          pow(rokokValue - csvRokokValue, 2) +
          pow(minumValue - csvMinumValue, 2) +
          pow(menghitungKaloriValue - csvMenghitungKaloriValue, 2) +
          pow(aktivitasValue - csvAktivitasValue, 2) +
          pow(teknologiValue - csvTeknologiValue, 2) +
          pow(alkoholValue - csvAlkoholValue, 2) +
          pow(transportasiValue - csvTransportasiValue, 2);
      final pangkat = sqrt(hitung);

      HasilAkhir.add({
        'result': pangkat,
        'diagnosis': csvDiagnosis,
      });
    }

    print('=================================');
    print(' Hasil Hitung Euclidean Distance ');
    print('=================================');

    HasilAkhir.sort((a, b) => a['result'].compareTo(b['result']));
    List<Map<String, dynamic>> terdekat = HasilAkhir.sublist(0, 4);
    for (int i = 0; i < terdekat.length; i++) {
      print('Empat Nilai Terdekat, Baris ke - [${i + 1}] : ${terdekat[i]}');
    }
    print('=================================');

    Map<String, int> diagnosisCount = {};
    for (var entry in terdekat) {
      String diagnosis = entry['diagnosis'];
      if (diagnosisCount.containsKey(diagnosis)) {
        diagnosisCount[diagnosis] = diagnosisCount[diagnosis]! + 1;
      } else {
        diagnosisCount[diagnosis] = 1;
      }
    }

    String mostFrequentDiagnosis = diagnosisCount.keys.first;
    int maxCount = diagnosisCount[mostFrequentDiagnosis]!;
    diagnosisCount.forEach((diagnosis, count) {
      if (count > maxCount) {
        mostFrequentDiagnosis = diagnosis;
        maxCount = count;
      }
    });

    print('Diagnosis Terbanyak: $mostFrequentDiagnosis');

    final prediction = _classifier?.predict(features).toMatrix();
    _predictionResult = prediction?[0][0]?.toString() ??
        'Prediksi Hasil Akhir = $mostFrequentDiagnosis';
    print(_predictionResult);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/result.gif',
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                const SizedBox(height: 16),
                const Text('Tingkat obesitas anda adalah: ',
                    style: TextStyle(fontSize: 16)),
                //pasang hasil akhir yang benarnya disini
                Text(
                  '${mostFrequentDiagnosis}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Tutup',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppsColor.accentColor,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadCSVData() async {
    final rawData = await rootBundle.loadString("assets/obesity_dataset.csv");
    List<List<dynamic>> data = const CsvToListConverter().convert(rawData);

    // final header = data.first;
    final rows = data.sublist(1);
    final samples = DataFrame(rows);
    final targetName = 'NObeyesdad';

    print(samples);
    print(samples.rows.length);

    // _classifier = KnnClassifier(
    //   samples,
    //   targetName,
    //   3, // The number of nearest neighbours
    //   distance: Distance.euclidean,
    // );

    final predict = _classifier!.predict(samples).toMatrix();

    predict[0][0].toString();
  }

  String predictObesity({
    required String gender,
    required double age,
    required double height,
    required double weight,
    required String familyHistoryWithOverweight,
    required String favc,
    required int fcvc,
    required double ncp,
    required String caec,
    required String smoke,
    required double ch2o,
    required String scc,
    required double faf,
    required double tue,
    required String calc,
    required String mtrans,
  }) {
    if (_classifier == null) {
      return 'Unknown';
    }

    final features = DataFrame([
      [
        gender,
        age,
        height,
        weight,
        familyHistoryWithOverweight,
        favc,
        fcvc,
        ncp,
        caec,
        smoke,
        ch2o,
        scc,
        faf,
        tue,
        calc,
        mtrans,
      ]
    ], headerExists: false);

    final predictedLabels = _classifier!.predict(features);

    return predictedLabels.rows.first.first.toString();
  }

  Future<void> predictObesityResult() async {
    if (_classifier == null) {
      await loadCSVData();
    }

    _predictionResult = predictObesity(
      gender: jenisKelaminController.text,
      age: double.parse(usiaController.text),
      height: double.parse(heightController.text),
      weight: double.parse(weightController.text),
      familyHistoryWithOverweight: selectedObecity?.label ?? '',
      favc: selectedCalories?.label ?? '',
      fcvc: int.parse(selectedVegetable?.label ?? "0"),
      ncp: double.parse(selectedNumberFrequenceEat?.label ?? "0.0"),
      caec: selectedSnack?.label ?? '',
      smoke: selectedCigarette?.label ?? "",
      ch2o: double.parse(selectedNumberFrequenceDrink?.label ?? "0.0"),
      scc: selectedCountingCalories?.label ?? "",
      faf: double.parse(selectedNumberFrequenceActivity?.label ?? "0.0"),
      tue: double.parse(selectedNumberFrequenceUseTech?.label ?? "0.0"),
      calc: selectedAlcohol?.label ?? "",
      mtrans: selectedTransportation?.label ?? "",
    );

    notifyListeners();
  }
}
