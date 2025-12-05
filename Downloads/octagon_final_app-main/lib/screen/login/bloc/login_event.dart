

// import 'package:equatable/equatable.dart';

// abstract class LoginScreenEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoginUserEvent extends LoginScreenEvent {
//   String? email;
//   String? password;
//   String? fcmToken;
//   LoginUserEvent({this.fcmToken,this.password, this.email,});

//   @override
//   List<Object?> get props => [password, email, fcmToken,];
// }

// class SocialAuthEvent extends LoginScreenEvent {
//   String? email;
//   String? socialId;
//   String? fcmToken;
//   SocialAuthEvent({this.fcmToken,this.socialId, this.email,});

//   @override
//   List<Object?> get props => [socialId, email, fcmToken,];
// }


// class VerifyOtpEvent extends LoginScreenEvent {
//   String? email;
//   String? otp;

//   VerifyOtpEvent({this.otp, this.email,});

//   @override
//   List<Object?> get props => [otp, email,];
// }

// class ResendOtpEvent extends LoginScreenEvent {
//   String? email;

//   ResendOtpEvent({ this.email,});

//   @override
//   List<Object?> get props => [email,];
// }

// class ForgetPasswordEvent extends LoginScreenEvent {
//   String? email;

//   ForgetPasswordEvent({ this.email,});

//   @override
//   List<Object?> get props => [email,];
// }

// class RegisterUserEvent extends LoginScreenEvent {
//   String? name;
//   String? email;
//   String? mobile;
//   String? password;
//   String? cPassword;
//   int gender = 1;
//   String? country;

//   RegisterUserEvent({ this.email,this.name,this.mobile,this.country,this.password,this.cPassword,this.gender = 1});

//   @override
//   List<Object?> get props => [email,name,mobile,country,password,cPassword,gender];
// }

// class EditProfileEvent extends LoginScreenEvent {
//   String? name;
//   String? dob;
//   String? country;
//   String? profilePic;
//   String? bgPic;
//   String? bio;

//   EditProfileEvent({ this.name,this.dob,this.country,this.profilePic,this.bgPic,this.bio});

//   @override
//   List<Object?> get props => [name,dob,country,profilePic,bgPic,bio];
// }