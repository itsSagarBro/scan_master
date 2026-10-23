import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_event.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_state.dart';

enum CodeCategory {
  url,
  upi,
  wifi,
  contact,
  text,
  email,
  sms,
  phone,
  code128,
  ean13,
  upca,
  aztec,
}

enum LogoType { none, appDefault, custom }

enum LogoShape { circle, roundedRect }

class CreateCodeBloc extends Bloc<CreateCodeEvent, CreateCodeState> {
  CreateCodeBloc() : super(const CreateCodeState()) {
    on<ChangeCategoryEvent>((event, emit) {
      emit(state.copyWith(
        category: event.category,
        generatedPayload: '',
      ));
    });

    on<UpdateColorEvent>((event, emit) {
      emit(state.copyWith(
        fgColor: event.fgColor,
        bgColor: event.bgColor,
      ));
    });

    on<UpdateQrRoundnessEvent>((event, emit) {
      emit(state.copyWith(qrRoundFactor: event.roundFactor));
    });

    on<UpdateFrameRadiusEvent>((event, emit) {
      emit(state.copyWith(frameCornerRadius: event.radius));
    });

    on<UpdateLogoShapeEvent>((event, emit) {
      emit(state.copyWith(logoShape: event.shape));
    });

    on<ChangeLogoTypeEvent>((event, emit) {
      emit(state.copyWith(
        logoType: event.logoType,
        customLogoFile: event.customFile,
        clearCustomLogo: event.logoType != LogoType.custom,
      ));
    });

    on<UpdateCaptionEvent>((event, emit) {
      emit(state.copyWith(caption: event.caption));
    });

    on<GenerateCodeEvent>((event, emit) {
      emit(state.copyWith(generatedPayload: event.payload));
    });
  }
}
