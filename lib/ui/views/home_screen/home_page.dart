import 'package:MedBuzz/core/auth/auth_service.dart';
import 'package:MedBuzz/core/constants/route_names.dart';
import 'package:MedBuzz/core/database/appointmentData.dart';
import 'package:MedBuzz/core/database/fitness_reminder.dart';
import 'package:MedBuzz/core/database/medication_data.dart';
import 'package:MedBuzz/core/database/user_db.dart';
import 'package:MedBuzz/core/database/waterReminderData.dart';
import 'package:MedBuzz/core/database/water_taken_data.dart';
import 'package:MedBuzz/ui/app_theme/app_theme.dart';
import 'package:MedBuzz/ui/darkmode/dark_mode_model.dart';
import 'package:MedBuzz/ui/navigation/app_navigation/app_transition.dart';
import 'package:MedBuzz/ui/views/all_reminders/all_reminders_screen.dart';
import 'package:MedBuzz/ui/views/home_screen/home_screen_model.dart';
import 'package:MedBuzz/ui/views/medication_reminders/all_medications_reminder_screen.dart';
import 'package:MedBuzz/ui/views/schedule-appointment/schedule_appointment_reminder_screen.dart';
import 'package:MedBuzz/ui/widget/appointment_card.dart';
import 'package:MedBuzz/ui/widget/custom_card.dart';
import 'package:MedBuzz/ui/widget/progress_card.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:MedBuzz/ui/size_config/config.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPressed = false;
  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool userPageDragging = false;
  Color color;

  Auth authenticateSession = Auth();
  void isBiometricAvailable() async {
    if (await authenticateSession.isBiometricAvailable() == true) {
      authenticateSession.authSession();
    }
  }

  @override
  void initState() {
    Provider.of<UserCrud>(context, listen: false).getuser();
    _menuPositionController = MenuPositionController(initPosition: 0);
    _pageController = PageController(
      initialPage: 0,
      keepPage: false,
    );
    _pageController.addListener(handlePageChange);
    isBiometricAvailable();

    super.initState();
  }

  void handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  void checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle) {
      userPageDragging = true;
    } else if (scrollNotification is ScrollEndNotification) {
      userPageDragging = false;
    }
    if (userPageDragging) {
      _menuPositionController.findNearestTarget(_pageController.page);
    }
  }

  @override
  Widget build(BuildContext context) {
    var userDb = Provider.of<UserCrud>(context);
    userDb.getuser();
    var model = Provider.of<HomeScreenModel>(context);

    var waterReminderDB = Provider.of<WaterReminderData>(context);
    waterReminderDB.getWaterReminders();

    var medicationDB = Provider.of<MedicationData>(context);
    medicationDB.getMedicationReminder();
    var waterTakenDB = Provider.of<WaterTakenData>(context, listen: true);
    waterTakenDB.getWaterTaken();
    var appointmentDB = Provider.of<AppointmentData>(context);
    appointmentDB.getAppointments();
    var fitnessDB = Provider.of<FitnessReminderCRUD>(context);
    fitnessDB.getReminders();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      model.updateAvailableMedicationReminders(medicationDB.medicationReminder);
      model.updateAvailableAppointmentReminders(appointmentDB.appointment);
    });

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final medModel = Provider.of<MedicationData>(context);
    Provider.of<MedicationData>(context).getMedicationReminder();

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).backgroundColor,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            checkUserDragging(notification);
          },
          child: PageView(
              onPageChanged: (page) => model.updateCurrentIndex(page),
              controller: _pageController,
              children: [
                WillPopScope(
                  onWillPop: () {
                    Navigation().pop();
                    return Future.value(false);
                  },
                  child: SafeArea(
                    child:
                        ListView(physics: BouncingScrollPhysics(), children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          Config.xMargin(context, 6),
                          Config.yMargin(context, 2),
                          Config.xMargin(context, 6),
                          Config.yMargin(context, 8.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      model.greeting(),
                                      style: TextStyle(
                                        fontSize: Config.xMargin(context, 5),
                                        color: color =
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    SizedBox(
                                      height: Config.yMargin(context, 2),
                                    ),
                                    Text(
                                      userDb.user?.name ?? '',
                                      style: TextStyle(
                                        fontSize: Config.xMargin(context, 6.66),
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(
                                      bottom: Config.xMargin(context, 8.33)),
                                  icon: Icon(Icons.invert_colors),
                                  iconSize: Config.xMargin(context, 8.33),
                                  color: Theme.of(context).primaryColorDark,
                                  onPressed: () {
                                    Provider.of<DarkModeModel>(context)
                                        .toggleAppTheme();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.05),
                            GestureDetector(
                              onTap: () {
                                FeatureDiscovery.discoverFeatures(
                                    context, const <String>{
                                  'feature7',
                                  'feature1',
                                  'feature2',
                                });
                                Navigator.pushReplacementNamed(
                                    context, RouteNames.waterScheduleView);
                              },
                              child: ProgressCard(
                                  child: Row(
                                    children: [
                                      Image.asset('images/waterdrop.png'),
                                      SizedBox(
                                        width: Config.xMargin(context, 3),
                                      ),
                                      Column(
                                        //mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Water Tracker',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: Config.textSize(
                                                    context, 3.5),
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                          ),
                                          SizedBox(
                                            height:
                                                Config.yMargin(context, 1.5),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '${waterTakenDB.currentLevel}ml',
                                                style: TextStyle(
                                                  fontSize: Config.textSize(
                                                      context, 4),
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                              ),
                                              Text(
                                                ' of ${waterTakenDB.totalLevel}ml',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: Config.textSize(
                                                      context, 4),
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  progressBarColor:
                                      Theme.of(context).primaryColor,
                                  title: 'Water Tracker',
                                  progress: waterTakenDB.currentLevel,
                                  total: waterTakenDB.totalLevel,
                                  width: width,
                                  height: height * 0.02),
                            ),
                            SizedBox(height: height * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, RouteNames.dietScheduleScreen),
                                    child: CustomCard(
                                        title: 'My meals',
                                        subtitle: 'View meal reminders',
                                        image: 'images/foood.png')),
                                GestureDetector(
                                    onTap: () => Navigator.pushNamed(context,
                                        RouteNames.fitnessSchedulesScreen),
                                    child: CustomCard(
                                        title: 'My fitness',
                                        subtitle: 'View fitness reminders',
                                        image: 'images/dumbell.png')),
                              ],
                            ),
                            SizedBox(height: height * 0.05),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.popAndPushNamed(
                                          context, RouteNames.medicationScreen);
                                    },
                                    child: Text(
                                      'Daily medications',
                                      style: TextStyle(
                                        fontSize: Config.textSize(context, 5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      // SharedPreferences prefs = await SharedPreferences.getInstance();
                                      // //Check if features introduction have been viewed before
                                      // bool value = await haveViewedIntroduction().then((value) => value);
                                      // if (!value) {
                                      // FeatureDiscovery.discoverFeatures(
                                      //   context,
                                      //   const <String>{
                                      //     'feature_1',
                                      //     'feature_2',
                                      //     'feature_3'
                                      //   }, //Add Others
                                      // );
                                      //   prefs.setBool('haveViewed', true);
                                      // }
                                      Navigator.popAndPushNamed(
                                          context, RouteNames.medicationScreen);
                                    },
                                    child: Text(
                                      'See all',
                                      style: TextStyle(
                                        fontSize: Config.textSize(context, 3.5),
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ]),
                            Visibility(
                              visible: model
                                  .medicationReminderBasedOnDateTime.isEmpty,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    'No Medication Reminder Set for this Date'),
                              ),
                            ),
                            Container(
                              //margin: EdgeInsets.only(
                              //  bottom: Config.yMargin(context, 2)),
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: model
                                            .medicationReminderBasedOnDateTime
                                            .length >
                                        3
                                    ? 3
                                    : model.medicationReminderBasedOnDateTime
                                        .length,
                                itemBuilder: (context, index) {
                                  return MedicationCard(
                                    height: height,
                                    width: width,
                                    values:
                                        model.medicationReminderBasedOnDateTime[
                                            index],
                                    drugName: model
                                        .medicationReminderBasedOnDateTime[
                                            index]
                                        .drugName,
                                    drugType: model
                                                .medicationReminderBasedOnDateTime[
                                                    index]
                                                .drugType ==
                                            'Injection'
                                        ? "images/injection.png"
                                        : model
                                                    .medicationReminderBasedOnDateTime[
                                                        index]
                                                    .drugType ==
                                                'Tablets'
                                            ? "images/tablets.png"
                                            : model
                                                        .medicationReminderBasedOnDateTime[
                                                            index]
                                                        .drugType ==
                                                    'Drops'
                                                ? "images/drops.png"
                                                : model
                                                            .medicationReminderBasedOnDateTime[
                                                                index]
                                                            .drugType ==
                                                        'Pills'
                                                    ? "images/pills.png"
                                                    : model
                                                                .medicationReminderBasedOnDateTime[
                                                                    index]
                                                                .drugType ==
                                                            'Ointment'
                                                        ? "images/ointment.png"
                                                        : model
                                                                    .medicationReminderBasedOnDateTime[
                                                                        index]
                                                                    .drugType ==
                                                                'Syrup'
                                                            ? "images/syrup.png"
                                                            : "images/inhaler.png",
                                    time: model
                                        .medicationReminderBasedOnDateTime[
                                            index]
                                        .firstTime
                                        .toString(),
                                    dosage: model
                                        .medicationReminderBasedOnDateTime[
                                            index]
                                        .dosage,
                                    selectedFreq: model
                                        .medicationReminderBasedOnDateTime[
                                            index]
                                        .frequency,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Upcoming appointments',
                                  style: TextStyle(
                                    fontSize: Config.textSize(context, 5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.popAndPushNamed(context,
                                        RouteNames.scheduledAppointmentsPage);
                                  },
                                  child: Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: Config.textSize(context, 3.5),
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                                visible: model
                                    .appointmentReminderBasedOnDateTime.isEmpty,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text('No Appointment Set for this Date'),
                                )),
                            for (var appointment
                                in model.appointmentReminderBasedOnDateTime)
                              AppointmentCard(
                                height: height,
                                width: width,
                                appointment: appointment,
                              )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                AllRemindersScreen(),
                // ProfilePage(), //Rempved fpr presentation purposes
              ]),
        ),
        floatingActionButton: model.currentIndex != 0
            ? Container()
            : WillPopScope(
                onWillPop: () {
                  Navigator.pushReplacementNamed(context, RouteNames.homePage);
                  return Future.value(false);
                },
                child: SpeedDial(
                  backgroundColor: Theme.of(context).primaryColor,
                  onOpen: () {
                    setState(() {
                      isPressed = true;
                    });
                  },
                  onClose: () {
                    setState(() {
                      isPressed = false;
                    });
                  },
                  child: Icon(isPressed == true ? Icons.close : Icons.add),
                  overlayColor: appThemeLight.iconTheme.color,
                  overlayOpacity: 0.7,
                  children: [
                    SpeedDialChild(
                      child: Image(image: AssetImage('images/calender.png')),
                      backgroundColor: Theme.of(context).primaryColorLight,
                      labelWidget: Container(
                        margin:
                            EdgeInsets.only(right: Config.xMargin(context, 4)),
                        child: Text(
                          'Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ScheduleAppointmentScreen(
                                    buttonText: 'Save',
                                  )),
                        );
                      },
                    ),
                    SpeedDialChild(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Image(image: AssetImage('images/drugoutline.png')),
                      labelWidget: Container(
                        margin:
                            EdgeInsets.only(right: Config.xMargin(context, 4)),
                        child: Text(
                          'Medication',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        medModel.newMedicine(context);
                      },
                    ),
                    SpeedDialChild(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Image(image: AssetImage('images/dumbell.png')),
                      labelWidget: Container(
                        margin:
                            EdgeInsets.only(right: Config.xMargin(context, 4)),
                        child: Text(
                          'Fitness',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.fitnessDescriptionScreen);
                      },
                    ),
                    SpeedDialChild(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Image(image: AssetImage('images/dropoutline.png')),
                      labelWidget: Container(
                        margin:
                            EdgeInsets.only(right: Config.xMargin(context, 4)),
                        child: Text(
                          'Water',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.scheduleWaterReminderScreen);
                      },
                    ),
                    SpeedDialChild(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Image(image: AssetImage('images/foood.png')),
                      labelWidget: Container(
                        margin:
                            EdgeInsets.only(right: Config.xMargin(context, 4)),
                        child: Text(
                          'Diet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.scheduleDietReminderScreen);
                      },
                    ),
                  ],
                ),
              ),
        //Crazelu extracted BottomNavigationBar widget to Widgets folder

        bottomNavigationBar: isPressed == true
            ? null
            : BubbledNavigationBar(
                controller: _menuPositionController,
                initialIndex: 0,
                defaultBubbleColor:
                    Theme.of(context).primaryColor.withOpacity(.2),
                backgroundColor: Theme.of(context).backgroundColor,
                onTap: (index) {
                  model.updateCurrentIndex(index);
                  _pageController.animateToPage(index,
                      duration: Duration(milliseconds: 150),
                      curve: Curves.easeInOutQuad);
                },
                items: <BubbledNavigationBarItem>[
                  BubbledNavigationBarItem(
                    icon: Icon(CupertinoIcons.home,
                        size: Config.xMargin(context, 8.33),
                        color: Theme.of(context).hintColor),
                    activeIcon: Icon(CupertinoIcons.home,
                        size: Config.xMargin(context, 8.33),
                        color: Theme.of(context).primaryColor),
                    title: Text(
                      'Home',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.w500,
                          fontSize: Config.textSize(context, 3.5)),
                    ),
                  ),
                  BubbledNavigationBarItem(
                    icon: Icon(CupertinoIcons.bell,
                        size: Config.xMargin(context, 8.33),
                        color: Theme.of(context).hintColor),
                    activeIcon: Icon(CupertinoIcons.bell,
                        size: Config.xMargin(context, 8.33),
                        color: Theme.of(context).primaryColor),
                    title: Text(
                      'Reminders',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.w500,
                          fontSize: Config.textSize(context, 3.5)),
                    ),
                  ),
                  // //Commented out for presentation Purposes
                  // BubbledNavigationBarItem(
                  //   icon: Icon(CupertinoIcons.profile_circled,
                  //       size: Config.xMargin(context, 8.33),
                  //       color: Theme.of(context).hintColor),
                  //   activeIcon: Icon(CupertinoIcons.profile_circled,
                  //       size: Config.xMargin(context, 8.33),
                  //       color: Theme.of(context).primaryColor),
                  //   title: Text(
                  //     'Profile',
                  //     style: TextStyle(
                  //         color: Theme.of(context).primaryColorDark,
                  //         fontWeight: FontWeight.w500,
                  //         fontSize: Config.textSize(context, 3.5)),
                  //   ),
                  // ),
                ],
              ));
  }
}
