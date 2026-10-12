// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodosDto _$TodosDtoFromJson(Map<String, dynamic> json) => _TodosDto(
  todos: (json['todos'] as List<dynamic>?)
      ?.map((e) => TodoDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TodosDtoToJson(_TodosDto instance) => <String, dynamic>{
  'todos': instance.todos,
};

_TodoDto _$TodoDtoFromJson(Map<String, dynamic> json) => _TodoDto(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  todo: json['todo'] as String?,
  completed: json['completed'] as bool?,
);

Map<String, dynamic> _$TodoDtoToJson(_TodoDto instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'todo': instance.todo,
  'completed': instance.completed,
};
