import 'package:octagon/model/update_profile_response_model.dart';
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/networking/model/response_model/login_response_model.dart';
import 'package:octagon/networking/model/response_model/register_response_model.dart';

class LoginInitialState extends LoginScreenState {}

class LoginLoadingBeginState extends LoginScreenState {}

class LoginLoadingEndState extends LoginScreenState {}

abstract class LoginScreenState {}
///login
class LoginUserState extends LoginScreenState {
  LoginResponseModel responseModel;

  LoginUserState(this.responseModel);
}

///verify otp
class VerifyOtpState extends LoginScreenState {
  LoginResponseModel responseModel;

  VerifyOtpState(this.responseModel);
}

///resend otp
class ResendOtpState extends LoginScreenState {
}

///forget password
class ForgetPasswordState extends LoginScreenState{}

///register user
class RegisterUserState extends LoginScreenState{
  RegisterResponseModel responseModel;
  RegisterUserState(this.responseModel);
}

///edit profile
class EditProfileState extends LoginScreenState{
  UpdateProfileResponseModel updateProfileResponseModel;
  EditProfileState(this.updateProfileResponseModel);
}

class LoginErrorState extends LoginScreenState {
  AppException exception;

  LoginErrorState(this.exception);
}