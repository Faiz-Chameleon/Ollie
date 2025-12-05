


// import 'package:octagon/main.dart';
// import 'package:octagon/networking/model/otp_verify_response_model.dart';
// import 'package:octagon/networking/model/resource.dart';
// import 'package:octagon/networking/model/response_model/login_response_model.dart';
// import 'package:octagon/networking/model/response_model/register_response_model.dart';
// import 'package:octagon/networking/network.dart';
// import 'package:octagon/screen/login/bloc/login_event.dart';
// import 'package:octagon/utils/constants.dart';

// import '../../../model/update_profile_response_model.dart';

// abstract class ILoginRepository {
//   Future loginUser(LoginUserEvent event);
// }
// class LoginRepository implements ILoginRepository {
//   static final LoginRepository _loginRepository = LoginRepository._init();

//   factory LoginRepository() {
//     return _loginRepository;
//   }

//   LoginRepository._init();

//   @override
//   Future loginUser(LoginUserEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//         body["password"] = event.password;
//       body["email"] = event.email;//emailOrPhone
//       body["fcm_token"] = event.fcmToken;
//       var result = await NetworkAPICall().multiPartPostRequest(loginApiUrl, body,false,"POST");
//       LoginResponseModel responseModel = LoginResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   @override
//   Future verifyOtp(VerifyOtpEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["otp"] = event.otp;
//       body["email"] = event.email;
//       body["fcm_token"] = storage.read("fcm_token");//emailOrPhone
//       var result = await NetworkAPICall().multiPartPostRequest(otpVerifyApiUrl, body,false,"POST");
//       LoginResponseModel responseModel = LoginResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   @override
//   Future resendOtp(ResendOtpEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["email"] = event.email;//emailOrPhone
//       var result = await NetworkAPICall().multiPartPostRequest(resendOtpApiUrl, body,false,"POST");

//       resource = Resource(
//         error: null,
//         data: result,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   @override
//   Future forgetPassword(ForgetPasswordEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["email"] = event.email;//emailOrPhone
//       var result = await NetworkAPICall().multiPartPostRequest(forgetPasswordApiUrl, body,false,"POST");
//       //LoginResponseModel responseModel = LoginResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: result,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   @override
//   Future registerUser(RegisterUserEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["name"] = event.name;
//       body["email"] = event.email;
//       body["mobile"] = event.mobile;
//       body["password"] = event.password;
//       body["country"] = event.country;
//       body["c_password"] = event.cPassword;
//       body["gender"] = event.gender;
//       var result = await NetworkAPICall().multiPartPostRequest(registerApiUrl, body,false,"POST");
//       RegisterResponseModel responseModel = RegisterResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   @override
//   Future editProfile(EditProfileEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["name"] = event.name;
//       body["dob"] = event.dob;
//       body["profilePic"] = event.profilePic;
//       if(event.bgPic!=null){
//         body["bgPic"] = event.bgPic;
//       }
//       body["country"] = event.country;
//       body["bio"] = event.bio;
//       var result = await NetworkAPICall().editProfileApi(profileUpdateUrl, body,true,"POST");
//       // RegisterResponseModel responseModel = RegisterResponseModel.fromJson(result);
//       UpdateProfileResponseModel responseModel = UpdateProfileResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   @override
//   Future socialAuth(SocialAuthEvent event) async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};

//       if(event.socialId!=null){
//         body["social_id"] = event.socialId;
//       }

//       if(event.email!=null){
//         body["email"] = event.email;
//       }
//       if(event.fcmToken!=null){
//         body["fcm_token"] = event.fcmToken;
//       }

//       var result = await NetworkAPICall().multiPartPostRequest(socialAuthUrl, body,false,"POST");

//       LoginResponseModel responseModel = LoginResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }


// }
