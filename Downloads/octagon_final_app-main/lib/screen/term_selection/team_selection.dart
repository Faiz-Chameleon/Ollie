import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/screen/login/login_controller.dart';

import 'package:octagon/screen/login/login_screen.dart';
import 'package:octagon/screen/sport%20/bloc/sport_bloc.dart';
import 'package:octagon/screen/sport%20/bloc/sport_event.dart';
import 'package:octagon/screen/sport%20/bloc/sport_state.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/theme/theme_notifier.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:shape_maker/shape_maker.dart';
import '../../networking/model/request_model/save_team_request_model.dart';
import '../../utils/common_image_view.dart';
import '../../utils/svg_to_png.dart';
import '../../utils/team_icon_bg.dart';

class TeamSelectionScreen extends StatefulWidget {
  List<Sports> sportDataList = [];
  bool isUpdate = false;

  TeamSelectionScreen(this.sportDataList, {super.key, this.isUpdate = false});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  bool isTapped = false;
  TextEditingController controller = TextEditingController();

  SportBloc sportBloc = SportBloc();
  List<TeamData> teamListResponseModel = [];
  List<TeamData> searchList = [];
  String selectedTeamLogo = "";
  TeamData? selectedTeam;

  bool isLoading = false;
  // List<SaveSportListResponseModelData> saveSportListResponseModelData = [];

  @override
  void initState() {
    List<String> tempValue = [];
    for (var element in widget.sportDataList) {
      if (element.selected) {
        tempValue.add(element.sportsName);
      }
    }

    /* if(tempValue.isNotEmpty && tempValue.firstOrNull !=null){

        searchList = [];
        isLoading = false;
        teamListResponseModel =  teamListResponseFromJson(storage.read(tempValue.first)).success??[];
        searchList.addAll(teamListResponseModel);
    }else{
      sportBloc.add(GetTeamListEvent(term: tempValue));
    }*/
    sportBloc.add(GetTeamListEvent(term: tempValue));

    publishAmplitudeEvent(eventType: 'Team Selection $kScreenView');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => widget.isUpdate);
      },
      child: SafeArea(
        child: Scaffold(
            backgroundColor: appBgColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              elevation: 0,
              centerTitle: true,
              title: Text(
                "${widget.isUpdate ? 'Update' : 'Select'} your favorite team",
                style: whiteColor20BoldTextStyle,
              ),
            ),
            body: BlocConsumer(
                bloc: sportBloc,
                listener: (context, state) {
                  if (state is SportLoadingBeginState) {
                    // onLoading(context);
                    isLoading = true;
                    setState(() {});
                  }
                  if (state is GetTermListState) {
                    // stopLoader(context);
                    searchList = [];
                    setState(() {
                      isLoading = false;
                      teamListResponseModel = state.teamListResponse.success ?? [];
                      searchList.addAll(state.teamListResponse.success ?? []);
                    });
                  }
                  if (state is SportErrorState) {
                    // stopLoader(context);
                    isLoading = false;
                    setState(() {});
                  }
                  if (state is SaveTermListState) {
                    // stopLoader(context);
                    isLoading = false;
                    setState(() {});
                    List<Map<String, dynamic>> data = [];
                    state.saveSportListResponseModel.success!.sportInfo?.forEach((element) {
                      // element.team!.add(TeamResponseModel(strTeamLogo: selectedTeamLogo));
                      data.add(element.toJson());
                    });

                    storage.write(sportInfo, data);

                    ///first team flag
                    storage.write(
                        'userDefaultTeam',
                        selectedTeamLogo.isNotEmpty
                            ? selectedTeamLogo
                            : state.saveSportListResponseModel.success!.sportInfo!.first.team!.first.strTeamLogo.toString());
                    storage.write('userDefaultTeamName', selectedTeam?.toJson());

                    if (widget.isUpdate) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TabScreen(
                                    selectedPage: 3,
                                  )));
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabScreen()));
                    }
                  }
                },
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.search),
                            title: TextField(
                              controller: controller,
                              decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none),
                              onChanged: onSearchTextChanged,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                controller.clear();
                                onSearchTextChanged('');
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: !isLoading,
                          replacement: const Center(child: CircularProgressIndicator()),
                          child: Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 8.0,
                              children: List.generate(searchList.length, (index) {
                                return getSports(searchList[index]);
                              }),
                            ),
                          )),
                      buildNextButton()
                    ],
                  );
                })),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      // return;
    }

    if (text.isNotEmpty) {
      for (var userDetail in teamListResponseModel) {
        if (userDetail.strTeam!.toLowerCase().contains(text.toLowerCase())) {
          searchList.add(userDetail);
        }
      }
    } else {
      searchList.addAll(teamListResponseModel);
    }

    setState(() {});
  }

// getSportsSelection() {
  //   List<Widget> list = [];
  //   for (int i = 0; i < teamListResponseModel.length; i++) {
  //     list.add(getSports(i));
  //   }
  //   return list;
  // }

  getSports(TeamData data) {
    /*  for (var element in selectedLanguages) {
      if(element == language[index].language){
        language[index].isSelected = true;
      }
    }*/
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTeamLogo = data.strTeamLogo ?? "";
          selectedTeam = data;
          searchList.forEach((element) {
            element.isSelected = false;
          });

          int currentIndex = searchList.indexWhere((element) => element.id == data.id);
          searchList[currentIndex].isSelected = !data.isSelected;

          // teamListResponseModel[index].isSelected
          //     ? teamListResponseModel.add(SaveSport(
          //     sportId: sportDataList[index].sportsId,
          //     sportApiId: sportDataList[index].sportApiId))
          //     : selectedSportsList.remove(SaveSport(
          //     sportId: sportDataList[index].sportsId,
          //     sportApiId: sportDataList[index].sportApiId));
        });
      },
      child: SizedBox(
        height: 130,
        width: 100,
        child: Column(
          children: <Widget>[
            buildSportSelectionWidget(isSelected: data.isSelected, image: data.strTeamLogo),
            // OctagonShape(
            //     height: 100,
            //     width: 100,
            //     bgColor: data.isSelected
            //         ? purpleColor
            //         : greyColor,
            //     child: Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Center(
            //     child: ImageViewWidget(image: data.strTeamLogo ?? "")
            //   ),
            // )),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Text(
                data.strTeam ?? "",
                textAlign: TextAlign.center,
                style: whiteColor14BoldTextStyle,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildNextButton() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: FilledButtonWidget(isLoading: isLoading, /*widget.model, */ widget.isUpdate ? "Update" : "Next", () {
          SaveTeamListRequestModel data = SaveTeamListRequestModel();
          List<SaveTeam> sportList = [];

          for (var element in teamListResponseModel.where((element) => element.isSelected ?? false).toList()) {
            sportList.add(SaveTeam(
                id: element.id!,
                idTeam: element.idTeam!,
                sport_id: widget.sportDataList[0].sportsId,
                sport_api_id: widget.sportDataList[0].sportApiId));
          }

          data.sports = sportList;
          if (data.sports != null && data.sports!.isNotEmpty) {
            sportBloc.add(SaveTeamListEvent(term: data.sports));
          } else {
            Get.snackbar("Octagon", "Please select at least 1 team!");
          }
        }, 1));
  }
}

buildSportSelectionWidget({bool isSelected = false, String? image}) {
  return ShapeMaker(
    height: 100,
    width: 100,
    bgColor: isSelected ? purpleColor : greyColor,
    widget: Container(
      margin: const EdgeInsets.all(8),
      child: ShapeMaker(
        bgColor: appBgColor,
        widget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: ImageViewWidget(image: image ?? "")),
        ),
      ),
    ),
  );
}

class Item {
  String imageUrl;
  int rank;

  Item(this.imageUrl, this.rank);
}

class GridItem extends StatefulWidget {
  final Key? key;
  final ValueChanged<bool>? isSelected;
  final String? name;
  String? image;

  GridItem({/*this.item, */ this.name, this.isSelected, this.image, this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected!(isSelected);
        });
      },
      child: SizedBox(
        height: 130,
        width: 100,
        child: Column(
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: isSelected ? purpleColor : greyColor),
              child: Center(
                  child: CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(widget.image ?? ""),
              )),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Text(
                widget.name ?? "",
                textAlign: TextAlign.center,
                style: whiteColor14BoldTextStyle,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
