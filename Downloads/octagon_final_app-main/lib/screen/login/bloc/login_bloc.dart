// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:octagon/networking/exception/exception.dart';
// import 'package:octagon/networking/model/resource.dart';
// import 'package:octagon/screen/login/bloc/login_event.dart';
// import 'package:octagon/screen/login/bloc/login_repo.dart';
// import 'package:octagon/screen/login/bloc/login_state.dart';

// class LoginBloc extends Bloc<LoginScreenEvent, LoginScreenState> {
//   LoginBloc() : super(LoginInitialState());

//   final LoginRepository _loginRepository = LoginRepository();

//   Stream<LoginScreenState> mapEventToState(LoginScreenEvent event) async* {
//     if (event is LoginUserEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.loginUser(event);
//       if (resource.data != null) {
//         yield LoginUserState(resource.data);
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }

//     if (event is VerifyOtpEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.verifyOtp(event);
//       if (resource.data != null) {
//         yield VerifyOtpState(resource.data);
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }

//     if (event is ResendOtpEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.resendOtp(event);
//       if (resource.data != null) {
//         yield ResendOtpState();
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }

//     if (event is ForgetPasswordEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.forgetPassword(event);
//       if (resource.data != null) {
//         yield ForgetPasswordState();
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }

//     if (event is RegisterUserEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.registerUser(event);
//       if (resource.data != null) {
//         yield RegisterUserState(resource.data);
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }

//     if (event is EditProfileEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.editProfile(event);
//       if (resource.data != null) {
//         yield EditProfileState(resource.data);
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }

//     if (event is SocialAuthEvent) {
//       yield LoginLoadingBeginState();
//       Resource resource = await _loginRepository.socialAuth(event);
//       if (resource.data != null) {
//         yield LoginUserState(resource.data);
//       } else {
//         yield LoginErrorState(AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield LoginLoadingEndState();
//     }
//   }
// }

// // class LoginBloc extends Bloc<LoginScreenEvent, LoginScreenState> {
// //   final LoginRepository _loginRepository = LoginRepository();

// //   LoginBloc() : super(LoginInitialState()) {
// //     // 1) Handle the login event
// //     on<LoginUserEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.loginUser(event);
// //       if (resource.data != null) {
// //         emit(LoginUserState(resource.data));
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });

// //     // 2) Handle OTP verification
// //     on<VerifyOtpEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.verifyOtp(event);
// //       if (resource.data != null) {
// //         emit(VerifyOtpState(resource.data));
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });

// //     // 3) Handle resending OTP
// //     on<ResendOtpEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.resendOtp(event);
// //       if (resource.data != null) {
// //         emit(ResendOtpState());
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });

// //     // 4) Handle forget password
// //     on<ForgetPasswordEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.forgetPassword(event);
// //       if (resource.data != null) {
// //         emit(ForgetPasswordState());
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });

// //     // 5) **Handle user registration** ← this is what you were missing
// //     on<RegisterUserEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.registerUser(event);
// //       if (resource.data != null) {
// //         emit(RegisterUserState(resource.data));
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });

// //     // 6) Handle profile edits
// //     on<EditProfileEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.editProfile(event);
// //       if (resource.data != null) {
// //         emit(EditProfileState(resource.data));
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });

// //     // 7) Handle social auth
// //     on<SocialAuthEvent>((event, emit) async {
// //       emit(LoginLoadingBeginState());
// //       final resource = await _loginRepository.socialAuth(event);
// //       if (resource.data != null) {
// //         emit(LoginUserState(resource.data));
// //       } else {
// //         emit(LoginErrorState(
// //           AppException.decodeExceptionData(jsonString: resource.error ?? ''),
// //         ));
// //       }
// //       emit(LoginLoadingEndState());
// //     });
// //   }
// // }
