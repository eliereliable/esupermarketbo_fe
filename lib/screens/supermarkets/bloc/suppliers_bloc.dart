import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'suppliers_event.dart';
part 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  SuppliersBloc() : super(SuppliersInitial()) {
    on<SuppliersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
