import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants/constants.dart';
import 'package:flutter_chatgpt/models/models_model.dart';
import 'package:flutter_chatgpt/providers/model_provider.dart';
import 'package:flutter_chatgpt/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({super.key});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String? currentModals;
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context, listen: false);
    currentModals = modelsProvider.getcurrentModel;
    return FutureBuilder<List<ModelsModel>>(
        future: modelsProvider.getAllModels(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Center(child: TextWidget(label: snapshot.error.toString()),);
          }
          return snapshot.data == null || snapshot.data!.isEmpty
              ? const SizedBox.shrink()
              : FittedBox(
                child: DropdownButton(
                dropdownColor: scaffoldBackgroundColor,
                iconEnabledColor: Colors.white,
                items:   List<DropdownMenuItem<String>>.generate(
                    snapshot.data!.length,
                        (index) => DropdownMenuItem(
                        value: snapshot.data![index].id,
                        child: TextWidget(
                          label: snapshot.data![index].id,
                          fontSize: 15,
                        ))),
                value: currentModals,
                onChanged: (value) {
                  setState(() {
                    currentModals = value.toString();
                  });
                  modelsProvider.setCurrentModel(value.toString(),);
                }),
              );
        }
    );
  }
}

/*

 */