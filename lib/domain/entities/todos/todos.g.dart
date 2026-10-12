// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Todos _$TodosFromJson(Map<String, dynamic> json) => _Todos(
  todos: (json['todos'] as List<dynamic>)
      .map((e) => Todo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TodosToJson(_Todos instance) => <String, dynamic>{
  'todos': instance.todos,
};

_Todo _$TodoFromJson(Map<String, dynamic> json) => _Todo(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  todo: json['todo'] as String,
  completed: json['completed'] as bool,
);

Map<String, dynamic> _$TodoToJson(_Todo instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'todo': instance.todo,
  'completed': instance.completed,
};
