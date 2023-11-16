import 'package:bloc/bloc.dart';

part 'create_event.dart';
part 'create_state.dart';

class CreateBloc extends Bloc<CreateEvent, CreateState> {
  CreateBloc() : super(CreateInitial()) {
    on<OnClickCreate>((event, emit) {});
  }
}
