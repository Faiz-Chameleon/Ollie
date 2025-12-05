import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:octagon/screen/setting/update_group_controller.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/CustomButton.dart';
import 'package:resize/resize.dart';

class UpdateGroupScreen extends StatefulWidget {
  final String groupId;

  const UpdateGroupScreen({super.key, required this.groupId});

  @override
  State<UpdateGroupScreen> createState() => _UpdateGroupScreenState();
}

class _UpdateGroupScreenState extends State<UpdateGroupScreen> {
  final UpdateGroupController controller = Get.put(UpdateGroupController());

  @override
  void initState() {
    super.initState();
    // Fetch group details when screen initializes
    controller.fetchGroupDetails(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appBgColor,
        appBar: AppBar(
          backgroundColor: appBgColor,
          elevation: 0,
          title: Text("Update Group", style: whiteColor24BoldTextStyle),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image upload section
                GestureDetector(
                  onTap: () => controller.showImagePickerOptions(context),
                  child: Column(
                    children: [
                      controller.isCompressing.value
                          ? const CircularProgressIndicator()
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
                                  : controller.groupData.value?.photo != null
                                      ? ClipOval(
                                          child: Image.network(
                                            "http://3.134.119.154/${controller.groupData.value!.photo!}",
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.add_a_photo,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.add_a_photo, color: Colors.white),
                            ),
                      const SizedBox(height: 8),
                      const Text("Upload Logo", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Group Name
                _input(controller.titleController, "Group Name"),
                const SizedBox(height: 30),

                // Updates section
                Align(alignment: Alignment.centerLeft, child: Text("Updates (Optional)", style: whiteColor16BoldTextStyle)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: controller.optionsController,
                  maxLength: 40, // Flutter automatically displays this count below the TextFormField
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Updates (Optional)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(12))),
                ),
                // _input(controller.optionsController, "Updates"),
                const SizedBox(height: 10),

                // Date picker
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
                TextFormField(
                  controller: controller.descriptionController,
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

                // Country
                // _input(controller.descriptionController, "Add Info", maxLines: 5),
                const SizedBox(height: 20),

                // Privacy toggle
                SwitchListTile(
                  value: controller.isPrivate.value,
                  onChanged: (val) => controller.isPrivate.value = val,
                  activeColor: Colors.deepPurple,
                  title: const Text("Make Group Private", style: TextStyle(color: Colors.white)),
                  secondary: const Icon(Icons.verified_user_rounded, color: Colors.deepPurple),
                ),
                const SizedBox(height: 30),

                // Update button
                CustomButton(
                  width: double.infinity,
                  height: 5.vh,
                  ButtonText: controller.isUpdating.value ? "Updating..." : "Update Group",
                  colors: Colors.deepPurple,
                  textColor: Colors.white,
                  tap: controller.isUpdating.value
                      ? null
                      : () async {
                          await controller.updateGroup(context);
                          // Check if update was successful and navigate back
                          if (!controller.isUpdating.value) {
                            Get.back();
                          }
                        },
                ),
              ],
            ),
          );
        }),
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
}
