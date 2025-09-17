part of 'suppliers_bloc.dart';

sealed class SuppliersState extends Equatable {
  const SuppliersState();
  
  @override
  List<Object> get props => [];
}

final class SuppliersInitial extends SuppliersState {}
