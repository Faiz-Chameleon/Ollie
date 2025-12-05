import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/groups/create_group_controller.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:intl/intl.dart';
import 'package:octagon/widgets/CustomButton.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:resize/resize.dart';

class CreateGroupScreen extends StatefulWidget {
  final String fromWhere;
  final String? teamName;

  CreateGroupScreen({super.key, required this.fromWhere, this.teamName});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final controller = Get.put(CreateGroupController());

  @override
  Widget build(BuildContext context) {
    final _teamNameController = TextEditingController(text: widget.teamName);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appBgColor,
        appBar: AppBar(
          backgroundColor: appBgColor,
          elevation: 0,
          title: Text("Create Group", style: whiteColor24BoldTextStyle),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => controller.showImagePickerOptions(context),
                    child: Column(
                      children: [
                        controller.isCompressing.value
                            ? CircularProgressIndicator()
                            : Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade600,
                                ),
                                child: controller.selectedImage.value != null
                                    ? ClipOval(
                                        child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover),
                                      )
                                    : const Icon(Icons.add_a_photo, color: Colors.white),
                              ),
                        const SizedBox(height: 8),
                        const Text("Upload Logo", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _input(
                    _teamNameController,
                    "Group Name",
                  ),
                  const SizedBox(height: 30),
                  Align(alignment: Alignment.centerLeft, child: Text("Updates (Optional)", style: whiteColor16BoldTextStyle)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.updateTextController,
                    maxLength: 40, // Flutter automatically displays this count below the TextFormField
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Updates",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(12))),
                  ),
                  // _input(controller.updateTextController, "Updates"),
                  const SizedBox(height: 10),
                  _input(controller.dateController, "Enter Date", readOnly: true, onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      controller.dateController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
                    }
                  }),
                  const SizedBox(height: 10),
                  _input(controller.countryController, "Country"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.infoController,
                    maxLength: 80, // Flutter automatically displays this count below the TextFormField
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Add Info",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    value: controller.isPrivate.value,
                    onChanged: (val) => controller.isPrivate.value = val,
                    activeColor: Colors.deepPurple,
                    title: const Text("Make Group Private", style: TextStyle(color: Colors.white)),
                    secondary: const Icon(Icons.verified_user_rounded, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    width: double.infinity,
                    height: 5.vh,
                    ButtonText: "Create Group",
                    colors: Colors.deepPurple,
                    textColor: Colors.white,
                    tap: () {
                      if (controller.selectedImage.value != null) {
                        controller.createGroup(context, fromWhere: widget.fromWhere, teamName: _teamNameController.text.trim());
                      } else {
                        Get.snackbar(backgroundColor: Colors.white, "Error", "Please Select a Photo For Group Icon");
                      }
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint, {int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _inputNew(TextEditingController controller, String hint,
      {int maxLines = 1, bool readOnly = false, VoidCallback? onTap, int maxLineLength = 40}) {
    // Added maxLineLength parameter
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1, // Ensure it shows at least 1 line
      maxLength: maxLines * maxLineLength, // Calculate total max characters
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(12)),
        counterText: '', // Hide the character counter
      ),
      // Prevent new lines beyond maxLines
      onChanged: (text) {
        final newLineCount = '\n'.allMatches(text).length + 1;
        if (newLineCount > maxLines) {
          final lastIndex = text.lastIndexOf('\n');
          controller.value = controller.value.copyWith(
            text: text.substring(0, lastIndex),
            selection: TextSelection.collapsed(offset: lastIndex),
          );
        }
      },
    );
  }

  Widget _input3(TextEditingController controller, String hint, {bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      maxLines: 2,
      minLines: 1,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(12)),
      ),
      // Prevent more than 2 lines
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}
