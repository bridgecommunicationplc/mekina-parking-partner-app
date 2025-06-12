import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/booking_parking_details_controller.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/mobile_number_textfield.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/themes/text_field_widget.dart';
import 'package:owner/ui/booking_process/parking_view_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

class BookingParkingDetailsScreen extends StatelessWidget {
  const BookingParkingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookingParkingDetailsController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface()
                .customAppBar(context, themeChange, "Select Date and Time".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'select_date'.tr,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontFamily: AppThemData.medium,
                          //     fontWeight: FontWeight.w700,
                          //     color: themeChange.getThem()
                          //         ? AppThemData.grey07
                          //         : AppThemData.grey07,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 5,
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       color: themeChange.getThem()
                          //           ? AppThemData.grey10
                          //           : AppThemData.grey03,
                          //       borderRadius: BorderRadius.circular(15)),
                          //   child: SfDateRangePicker(
                          //     selectionMode:
                          //         DateRangePickerSelectionMode.single,
                          //     view: DateRangePickerView.month,
                          //     selectionColor: AppThemData.primary06,
                          //     selectionTextStyle:
                          //         const TextStyle(color: Colors.black),
                          //     onSelectionChanged:
                          //         (dateRangePickerSelectionChangedArgs) {
                          //       controller.selectedDateTime.value =
                          //           dateRangePickerSelectionChangedArgs.value;
                          //     },
                          //     minDate: DateTime.now(),
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          // Text(
                          //   'duration'.tr,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontFamily: AppThemData.medium,
                          //     fontWeight: FontWeight.w700,
                          //     color: themeChange.getThem()
                          //         ? AppThemData.grey07
                          //         : AppThemData.grey07,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Obx(
                          //   () => Slider(
                          //     value: controller.selectedDuration.value,
                          //     onChanged: (value) {
                          //       controller.selectedDuration.value = value;
                          //
                          //       controller.startTimeController.value.text =
                          //           DateFormat('HH:mm')
                          //               .format(controller.startTime.value);
                          //       Duration duration = Duration(
                          //           hours: controller.selectedDuration.value
                          //               .toInt());
                          //
                          //       controller.endTime.value =
                          //           controller.startTime.value.add(duration);
                          //       controller.endTimeController.value.text =
                          //           DateFormat('HH:mm')
                          //               .format(controller.endTime.value);
                          //     },
                          //     autofocus: false,
                          //     activeColor: AppThemData.primary06,
                          //     inactiveColor: AppThemData.grey03,
                          //     min: 0,
                          //     max: 24,
                          //     divisions: 24,
                          //     label:
                          //         "${controller.selectedDuration.value.round().toString()} hours"
                          //             .tr,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Text(
                          //   'Select Time'.tr,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontFamily: AppThemData.medium,
                          //     fontWeight: FontWeight.w700,
                          //     color: themeChange.getThem()
                          //         ? AppThemData.grey07
                          //         : AppThemData.grey07,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 14,
                          // ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: InkWell(
                          //         onTap: () async {
                          //           TimeOfDay? startTime =
                          //               await Constant.selectTime(context);
                          //
                          //           if (startTime != null) {
                          //             controller.startTime.value = DateTime(
                          //                 controller
                          //                     .selectedDateTime.value.year,
                          //                 controller
                          //                     .selectedDateTime.value.month,
                          //                 controller.selectedDateTime.value.day,
                          //                 startTime.hour,
                          //                 startTime.minute);
                          //
                          //             controller
                          //                     .startTimeController.value.text =
                          //                 DateFormat('HH:mm').format(
                          //                     controller.startTime.value);
                          //
                          //             Duration duration = Duration(
                          //                 hours: controller
                          //                     .selectedDuration.value
                          //                     .toInt());
                          //
                          //             controller.endTime.value = controller
                          //                 .startTime.value
                          //                 .add(duration);
                          //             controller.endTimeController.value.text =
                          //                 DateFormat('HH:mm')
                          //                     .format(controller.endTime.value);
                          //           }
                          //         },
                          //         child: TextFieldWidget(
                          //           onPress: () {},
                          //           controller:
                          //               controller.startTimeController.value,
                          //           textInputType:
                          //               const TextInputType.numberWithOptions(
                          //                   decimal: true, signed: true),
                          //           inputFormatters: [
                          //             FilteringTextInputFormatter.allow(
                          //                 RegExp('[0-9]')),
                          //           ],
                          //           hintText: 'Select Time'.tr,
                          //           enable: false,
                          //           prefix: Padding(
                          //             padding: const EdgeInsets.all(12.0),
                          //             child: SvgPicture.asset(
                          //               "assets/icon/ic_clock.svg",
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(
                          //       width: 10,
                          //     ),
                          //     Expanded(
                          //       child: InkWell(
                          //         onTap: () async {
                          //           TimeOfDay? startTime =
                          //               await Constant.selectTime(context);
                          //
                          //           if (startTime != null) {
                          //             controller.endTime.value = DateTime(
                          //                 controller
                          //                     .selectedDateTime.value.year,
                          //                 controller
                          //                     .selectedDateTime.value.month,
                          //                 controller.selectedDateTime.value.day,
                          //                 startTime.hour,
                          //                 startTime.minute);
                          //
                          //             controller.endTimeController.value.text =
                          //                 DateFormat('HH:mm')
                          //                     .format(controller.endTime.value);
                          //
                          //             Duration duration = Duration(
                          //                 hours: controller
                          //                     .selectedDuration.value
                          //                     .toInt());
                          //
                          //             controller.startTime.value = controller
                          //                 .endTime.value
                          //                 .subtract(duration);
                          //             controller
                          //                     .startTimeController.value.text =
                          //                 DateFormat('HH:mm').format(
                          //                     controller.startTime.value);
                          //           }
                          //         },
                          //         child: TextFieldWidget(
                          //           onPress: () {},
                          //           controller:
                          //               controller.endTimeController.value,
                          //           textInputType:
                          //               const TextInputType.numberWithOptions(
                          //                   decimal: true, signed: true),
                          //           inputFormatters: [
                          //             FilteringTextInputFormatter.allow(
                          //                 RegExp('[0-9]')),
                          //           ],
                          //           hintText: 'Select Time'.tr,
                          //           enable: false,
                          //           prefix: Padding(
                          //             padding: const EdgeInsets.all(12.0),
                          //             child: SvgPicture.asset(
                          //               "assets/icon/ic_clock.svg",
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(
                            height: 5,
                          ),
                          // Text(
                          //   'Vehicle Number Plate'.tr,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontFamily: AppThemData.medium,
                          //     fontWeight: FontWeight.w700,
                          //     color: themeChange.getThem()
                          //         ? AppThemData.grey07
                          //         : AppThemData.grey07,
                          //   ),
                          // ),
                          TextFieldWidget(
                            title: 'Vehicle Number Plate'.tr,
                            onPress: () {},
                            controller: controller.vehiclePlateController.value,
                            hintText: 'Enter Vehicle Number Plate'.tr,
                            textInputType: TextInputType.text,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                  "assets/icon/ic_account.svg",
                                  color: const Color(0xff697586)),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Customer Name'.tr,
                            onPress: () {},
                            controller: controller.customerNameController.value,
                            hintText: 'Enter Customer Name'.tr,
                            textInputType: TextInputType.emailAddress,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                  "assets/icon/ic_account.svg",
                                  color: const Color(0xff697586)),
                            ),
                          ),
                          MobileNumberTextField(
                            title: "Phone Number".tr,
                            controller: controller.phoneNumberController.value,
                            countryCodeController: controller.countryCode.value,
                            onPress: () {},
                          ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: DropdownSearch<UserVehicleModel>(
                          //         key: controller.userVehicleKey,
                          //         popupProps: PopupProps.menu(
                          //           showSearchBox: true,
                          //           searchFieldProps: TextFieldProps(
                          //             decoration: InputDecoration(
                          //               labelText: "Search vehicle",
                          //               border: OutlineInputBorder(
                          //                 borderRadius:
                          //                     BorderRadius.circular(12),
                          //               ),
                          //             ),
                          //           ),
                          //           showSelectedItems: true,
                          //         ),
                          //         dropdownDecoratorProps:
                          //             DropDownDecoratorProps(
                          //           dropdownSearchDecoration: InputDecoration(
                          //             hintText: "Select vehicle",
                          //             hintStyle: TextStyle(
                          //               fontSize: 14,
                          //               color: themeChange.getThem()
                          //                   ? AppThemData.grey06
                          //                   : AppThemData.grey06,
                          //               fontWeight: FontWeight.w500,
                          //               fontFamily: AppThemData.medium,
                          //             ),
                          //             errorStyle:
                          //                 const TextStyle(color: Colors.red),
                          //             isDense: true,
                          //             filled: true,
                          //             fillColor: themeChange.getThem()
                          //                 ? AppThemData.grey10
                          //                 : AppThemData.grey03,
                          //             contentPadding:
                          //                 const EdgeInsets.symmetric(
                          //                     vertical: 16, horizontal: 10),
                          //             prefixIcon: Padding(
                          //               padding: const EdgeInsets.all(8.0),
                          //               child: SvgPicture.asset(
                          //                 "assets/icon/ic_car_image.svg",
                          //                 height: 20,
                          //                 width: 20,
                          //               ),
                          //             ),
                          //             border: UnderlineInputBorder(
                          //               borderRadius: BorderRadius.circular(12),
                          //               borderSide: BorderSide(
                          //                 color: themeChange.getThem()
                          //                     ? AppThemData.grey09
                          //                     : AppThemData.grey04,
                          //                 width: 1,
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //         validator: (value) {
                          //           if (value == null) {
                          //             return "Please select a vehicle";
                          //           }
                          //           return null;
                          //         },
                          //         compareFn: (UserVehicleModel? item1,
                          //                 UserVehicleModel? item2) =>
                          //             item1?.userId == item2?.userId,
                          //         items: controller.allUserVehicle,
                          //         itemAsString: (UserVehicleModel? item) {
                          //           return "${item?.vehicleModel?.name} (${item?.vehicleNumber})";
                          //         },
                          //         selectedItem: controller
                          //                     .selectedUserVehicleModel
                          //                     .value
                          //                     .userId ==
                          //                 null
                          //             ? null
                          //             : controller
                          //                 .selectedUserVehicleModel.value,
                          //         onChanged: (value) async {
                          //           if (value != null) {
                          //             controller.selectedUserVehicleModel
                          //                 .value = value;
                          //             controller.update();
                          //             await FireStoreUtils.getUser(
                          //                     value.userId!)
                          //                 .then((userVehicles) {
                          //               if (userVehicles != null) {
                          //                 controller.user.value = userVehicles;
                          //               }
                          //             });
                          //           }
                          //         },
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 8,
                          //     ),
                          //     InkWell(
                          //       onTap: () async {
                          //         final result =
                          //             await Get.to(() => AddNewVehicleScreen());
                          //         if (result == true) {
                          //           await FireStoreUtils.getAllUserVehicle()
                          //               .then((value) {
                          //             if (value != null) {
                          //               controller.allUserVehicle.value = value;
                          //             }
                          //           });
                          //         }
                          //       },
                          //       child: Container(
                          //         height: 40,
                          //         width: 40,
                          //         decoration: BoxDecoration(
                          //           color: AppThemData.primary06,
                          //           borderRadius: BorderRadius.circular(25.0),
                          //         ),
                          //         child: Icon(
                          //           Icons.add,
                          //           color: Colors.white,
                          //           size: 20,
                          //         ),
                          //       ),
                          //     )
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Text(
                          //   'Select Customer'.tr,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontFamily: AppThemData.medium,
                          //     fontWeight: FontWeight.w700,
                          //     color: themeChange.getThem()
                          //         ? AppThemData.grey07
                          //         : AppThemData.grey07,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: DropdownButtonFormField<UserModel>(
                          //           isExpanded: true,
                          //           key: controller.key,
                          //           validator: (value) {
                          //             if (value == null) {
                          //               return "Please select customer";
                          //             }
                          //             return null;
                          //           },
                          //           decoration: InputDecoration(
                          //             errorStyle:
                          //                 const TextStyle(color: Colors.red),
                          //             isDense: true,
                          //             filled: true,
                          //             fillColor: themeChange.getThem()
                          //                 ? AppThemData.grey10
                          //                 : AppThemData.grey03,
                          //             contentPadding:
                          //                 const EdgeInsets.symmetric(
                          //                     vertical: 16, horizontal: 10),
                          //             prefixIcon: Padding(
                          //               padding: const EdgeInsets.all(8.0),
                          //               child: SvgPicture.asset(
                          //                   "assets/icon/ic_user.svg",
                          //                   height: 20,
                          //                   width: 20),
                          //             ),
                          //             disabledBorder: UnderlineInputBorder(
                          //               borderRadius: const BorderRadius.only(
                          //                   topLeft: Radius.circular(12),
                          //                   topRight: Radius.circular(12)),
                          //               borderSide: BorderSide(
                          //                   color: themeChange.getThem()
                          //                       ? AppThemData.grey09
                          //                       : AppThemData.grey04,
                          //                   width: 1),
                          //             ),
                          //             focusedBorder: UnderlineInputBorder(
                          //               borderRadius: const BorderRadius.only(
                          //                   topLeft: Radius.circular(12),
                          //                   topRight: Radius.circular(12)),
                          //               borderSide: BorderSide(
                          //                   color: themeChange.getThem()
                          //                       ? AppThemData.primary06
                          //                       : AppThemData.primary06,
                          //                   width: 1),
                          //             ),
                          //             enabledBorder: UnderlineInputBorder(
                          //               borderRadius: const BorderRadius.only(
                          //                   topLeft: Radius.circular(12),
                          //                   topRight: Radius.circular(12)),
                          //               borderSide: BorderSide(
                          //                   color: themeChange.getThem()
                          //                       ? AppThemData.grey09
                          //                       : AppThemData.grey04,
                          //                   width: 1),
                          //             ),
                          //             errorBorder: UnderlineInputBorder(
                          //               borderRadius: const BorderRadius.only(
                          //                   topLeft: Radius.circular(12),
                          //                   topRight: Radius.circular(12)),
                          //               borderSide: BorderSide(
                          //                   color: themeChange.getThem()
                          //                       ? AppThemData.grey09
                          //                       : AppThemData.grey04,
                          //                   width: 1),
                          //             ),
                          //             border: UnderlineInputBorder(
                          //               borderRadius: const BorderRadius.only(
                          //                   topLeft: Radius.circular(12),
                          //                   topRight: Radius.circular(12)),
                          //               borderSide: BorderSide(
                          //                   color: themeChange.getThem()
                          //                       ? AppThemData.grey09
                          //                       : AppThemData.grey04,
                          //                   width: 1),
                          //             ),
                          //             hintStyle: TextStyle(
                          //                 fontSize: 14,
                          //                 color: themeChange.getThem()
                          //                     ? AppThemData.grey06
                          //                     : AppThemData.grey06,
                          //                 fontWeight: FontWeight.w500,
                          //                 fontFamily: AppThemData.medium),
                          //           ),
                          //           value:
                          //               controller.selectedUser.value.id == null
                          //                   ? null
                          //                   : controller.selectedUser.value,
                          //           onChanged: (value) async {
                          //             if (value != null) {
                          //               controller.selectedUser.value = value;
                          //               controller.update();
                          //             }
                          //           },
                          //           style: TextStyle(
                          //               fontSize: 14,
                          //               color: themeChange.getThem()
                          //                   ? AppThemData.grey02
                          //                   : AppThemData.grey08,
                          //               fontWeight: FontWeight.w500,
                          //               fontFamily: AppThemData.medium),
                          //           hint: Text(
                          //             "Select customer".tr,
                          //             style: TextStyle(
                          //                 color: themeChange.getThem()
                          //                     ? AppThemData.grey07
                          //                     : AppThemData.grey07),
                          //           ),
                          //           items:
                          //               controller.user.map((UserModel item) {
                          //             return DropdownMenuItem<UserModel>(
                          //               value: item,
                          //               child: Text(
                          //                   "${item.fullName!.toString()} (${item.phoneNumber!.toString()})",
                          //                   style: const TextStyle()),
                          //             );
                          //           }).toList()),
                          //     ),
                          //     const SizedBox(
                          //       width: 8,
                          //     ),
                          //     InkWell(
                          //       onTap: () async {
                          //         final result =
                          //             await Get.to(() => AddNewUserScreen());
                          //         if (result == true) {
                          //           await FireStoreUtils.getAllUser()
                          //               .then((value) {
                          //             if (value != null) {
                          //               controller.user.value = value;
                          //             }
                          //           });
                          //           controller.update();
                          //         }
                          //       },
                          //       child: Container(
                          //         height: 40,
                          //         width: 40,
                          //         decoration: BoxDecoration(
                          //           color: AppThemData.primary06,
                          //           borderRadius: BorderRadius.circular(25.0),
                          //         ),
                          //         child: Icon(
                          //           Icons.add,
                          //           color: Colors.white,
                          //           size: 20,
                          //         ),
                          //       ),
                          //     )
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 15,
                          // ),

                          // SingleChildScrollView(
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(20.0),
                          //     child: GridView.builder(
                          //         physics: NeverScrollableScrollPhysics(),
                          //         itemCount: int.parse(controller
                          //             .parkingModel.value.parkingSpace
                          //             .toString()),
                          //         shrinkWrap: true,
                          //         padding: const EdgeInsets.all(4.0),
                          //         gridDelegate:
                          //             const SliverGridDelegateWithFixedCrossAxisCount(
                          //                 crossAxisCount: 2,
                          //                 childAspectRatio: 1.5),
                          //         itemBuilder: (context, int index) {
                          //           return Obx(
                          //             () {
                          //               var isBooked = controller
                          //                   .selectedOrderModel
                          //                   .where((element) =>
                          //                       element.parkingSlotId
                          //                           .toString() ==
                          //                       "A-${index + 1}");
                          //               return InkWell(
                          //                 onTap: () {
                          //                   if (isBooked.isEmpty) {
                          //                     controller.selectedParking.value =
                          //                         "A-${index + 1}";
                          //                   }
                          //                 },
                          //                 child: Container(
                          //                   decoration: BoxDecoration(
                          //                       border: Border(
                          //                           right: index.isEven
                          //                               ? const BorderSide(
                          //                                   color: AppThemData
                          //                                       .grey04)
                          //                               : BorderSide.none,
                          //                           bottom: const BorderSide(
                          //                               color:
                          //                                   AppThemData.grey04),
                          //                           top: const BorderSide(
                          //                               color:
                          //                                   AppThemData.grey04),
                          //                           left: index.isOdd
                          //                               ? const BorderSide(
                          //                                   color: AppThemData
                          //                                       .grey04)
                          //                               : BorderSide.none)),
                          //                   child: isBooked.isNotEmpty
                          //                       ? Padding(
                          //                           padding:
                          //                               const EdgeInsets.all(
                          //                                   20.0),
                          //                           child: Image.asset(
                          //                             "assets/images/car_image.png",
                          //                           ),
                          //                         )
                          //                       : controller.selectedParking
                          //                                   .value ==
                          //                               "A-${index + 1}"
                          //                           ? Container(
                          //                               padding:
                          //                                   const EdgeInsets
                          //                                       .symmetric(
                          //                                       horizontal: 10),
                          //                               decoration: BoxDecoration(
                          //                                   color: themeChange
                          //                                           .getThem()
                          //                                       ? AppThemData
                          //                                           .grey10
                          //                                       : AppThemData
                          //                                           .grey04),
                          //                               child: Row(
                          //                                 mainAxisAlignment:
                          //                                     MainAxisAlignment
                          //                                         .center,
                          //                                 crossAxisAlignment:
                          //                                     CrossAxisAlignment
                          //                                         .center,
                          //                                 children: [
                          //                                   SvgPicture.asset(
                          //                                       "assets/icon/ic_parking_select.svg",
                          //                                       width: 24,
                          //                                       height: 24),
                          //                                   const SizedBox(
                          //                                     width: 10,
                          //                                   ),
                          //                                   Text(
                          //                                     'A-${index + 1}',
                          //                                     style: TextStyle(
                          //                                       fontSize: 16,
                          //                                       fontFamily:
                          //                                           AppThemData
                          //                                               .medium,
                          //                                       color: themeChange.getThem()
                          //                                           ? AppThemData
                          //                                               .primary06
                          //                                           : AppThemData
                          //                                               .primary07,
                          //                                     ),
                          //                                   ),
                          //                                 ],
                          //                               ),
                          //                             )
                          //                           : Padding(
                          //                               padding:
                          //                                   const EdgeInsets
                          //                                       .symmetric(
                          //                                       horizontal: 20),
                          //                               child: Center(
                          //                                 child: Text(
                          //                                   'A-${index + 1}',
                          //                                   style: TextStyle(
                          //                                     fontSize: 16,
                          //                                     fontFamily:
                          //                                         AppThemData
                          //                                             .medium,
                          //                                     color: themeChange
                          //                                             .getThem()
                          //                                         ? AppThemData
                          //                                             .grey08
                          //                                         : AppThemData
                          //                                             .grey08,
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                 ),
                          //               );
                          //             },
                          //           );
                          //         }),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemData.grey10
                  : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Next".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    // if (controller.selectedUserVehicleModel.value.id == null) {
                    //   ShowToastDialog.showToast(
                    //       "Please select your vehicle".tr);
                    // } else if (controller.selectedUser.value.id == null) {
                    //   ShowToastDialog.showToast(
                    //       "Please select your customer".tr);
                    // }
                    if (controller.vehiclePlateController.value.text == null &&
                        controller.vehiclePlateController.value.text.isEmpty) {
                      ShowToastDialog.showToast(
                          "Please select your vehicle number plate".tr);
                    } else if (controller.customerNameController.value.text ==
                            null &&
                        controller.customerNameController.value.text.isEmpty) {
                      ShowToastDialog.showToast(
                          "Please select customer name".tr);
                    } else if (controller.phoneNumberController.value.text ==
                            null &&
                        controller.phoneNumberController.value.text.isEmpty) {
                      ShowToastDialog.showToast(
                          "Please select phone number".tr);
                    } else if (controller.selectedDuration.value < 1) {
                      ShowToastDialog.showToast(
                          "Please select duration minimum one hour".tr);
                    } else {
                      OrderModel orderModel = OrderModel();

                      Timestamp startTime = Timestamp.now();
                      String customerPhone =
                          "${controller.countryCode.value.text}${controller.phoneNumberController.value.text}";
                      orderModel.parkingDetails = controller.parkingModel.value;
                      UserModel? userModel =
                          await FireStoreUtils.getUserProfile(
                              orderModel.parkingDetails!.userId.toString());
                      orderModel.userVehicle =
                          controller.selectedUserVehicleModel.value;
                      // orderModel.userVehicle =
                      //    UserVehicleModel();
                      orderModel.duration =
                          controller.selectedDuration.value.toString();
                      orderModel.bookingDate = Timestamp.fromDate(DateTime(
                          controller.selectedDateTime.value.year,
                          controller.selectedDateTime.value.month,
                          controller.selectedDateTime.value.day));
                      orderModel.bookingStartTime = startTime;

                      if (userModel!.adminCommission != null &&
                          userModel.adminCommission!.toJson().isNotEmpty &&
                          userModel.adminCommission!
                              .toJson()
                              .values
                              .any((element) => element != null)) {
                        orderModel.adminCommission = userModel.adminCommission;
                      } else {
                        orderModel.adminCommission = Constant.adminCommission;
                      }

                      orderModel.bookingEndTime =
                          Timestamp.fromMillisecondsSinceEpoch(
                              startTime.millisecondsSinceEpoch +
                                  Duration(hours: 1).inMilliseconds);
                      orderModel.status = Constant.placed;
                      orderModel.userId = controller.selectedUser.value.id;
                      orderModel.id = Constant.getUuid();
                      orderModel.parkingId = controller.parkingModel.value.id;
                      orderModel.perHrPrice =
                          controller.parkingModel.value.perHrPrice;
                      orderModel.subTotal =
                          controller.calculateParkingAmount().toString();
                      orderModel.taxList = Constant.taxList;
                      orderModel.notificationSent = false;
                      orderModel.bookedBy = "Owner";
                      // orderModel.parkingSlotId =
                      //     controller.selectedParking.value;
                      orderModel.createdAt = Timestamp.now();
                      orderModel.updateAt = Timestamp.now();
                      orderModel.vehicleNumberPlate =
                          controller.vehiclePlateController.value.text;
                      orderModel.customerName =
                          controller.customerNameController.value.text;
                      orderModel.customerPhoneNumber = customerPhone.toString();

                      Get.to(() => const ParkingViewScreen(),
                          arguments: {"orderModel": orderModel});
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
