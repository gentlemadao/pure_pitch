// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pitch_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimestampedPitch {

 DateTime get time; double get hz; int get midiNote; double get clarity; double get amplitude;
/// Create a copy of TimestampedPitch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimestampedPitchCopyWith<TimestampedPitch> get copyWith => _$TimestampedPitchCopyWithImpl<TimestampedPitch>(this as TimestampedPitch, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimestampedPitch&&(identical(other.time, time) || other.time == time)&&(identical(other.hz, hz) || other.hz == hz)&&(identical(other.midiNote, midiNote) || other.midiNote == midiNote)&&(identical(other.clarity, clarity) || other.clarity == clarity)&&(identical(other.amplitude, amplitude) || other.amplitude == amplitude));
}


@override
int get hashCode => Object.hash(runtimeType,time,hz,midiNote,clarity,amplitude);

@override
String toString() {
  return 'TimestampedPitch(time: $time, hz: $hz, midiNote: $midiNote, clarity: $clarity, amplitude: $amplitude)';
}


}

/// @nodoc
abstract mixin class $TimestampedPitchCopyWith<$Res>  {
  factory $TimestampedPitchCopyWith(TimestampedPitch value, $Res Function(TimestampedPitch) _then) = _$TimestampedPitchCopyWithImpl;
@useResult
$Res call({
 DateTime time, double hz, int midiNote, double clarity, double amplitude
});




}
/// @nodoc
class _$TimestampedPitchCopyWithImpl<$Res>
    implements $TimestampedPitchCopyWith<$Res> {
  _$TimestampedPitchCopyWithImpl(this._self, this._then);

  final TimestampedPitch _self;
  final $Res Function(TimestampedPitch) _then;

/// Create a copy of TimestampedPitch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? hz = null,Object? midiNote = null,Object? clarity = null,Object? amplitude = null,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,hz: null == hz ? _self.hz : hz // ignore: cast_nullable_to_non_nullable
as double,midiNote: null == midiNote ? _self.midiNote : midiNote // ignore: cast_nullable_to_non_nullable
as int,clarity: null == clarity ? _self.clarity : clarity // ignore: cast_nullable_to_non_nullable
as double,amplitude: null == amplitude ? _self.amplitude : amplitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TimestampedPitch].
extension TimestampedPitchPatterns on TimestampedPitch {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimestampedPitch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimestampedPitch() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimestampedPitch value)  $default,){
final _that = this;
switch (_that) {
case _TimestampedPitch():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimestampedPitch value)?  $default,){
final _that = this;
switch (_that) {
case _TimestampedPitch() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime time,  double hz,  int midiNote,  double clarity,  double amplitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimestampedPitch() when $default != null:
return $default(_that.time,_that.hz,_that.midiNote,_that.clarity,_that.amplitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime time,  double hz,  int midiNote,  double clarity,  double amplitude)  $default,) {final _that = this;
switch (_that) {
case _TimestampedPitch():
return $default(_that.time,_that.hz,_that.midiNote,_that.clarity,_that.amplitude);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime time,  double hz,  int midiNote,  double clarity,  double amplitude)?  $default,) {final _that = this;
switch (_that) {
case _TimestampedPitch() when $default != null:
return $default(_that.time,_that.hz,_that.midiNote,_that.clarity,_that.amplitude);case _:
  return null;

}
}

}

/// @nodoc


class _TimestampedPitch implements TimestampedPitch {
  const _TimestampedPitch(this.time, {required this.hz, required this.midiNote, required this.clarity, required this.amplitude});
  

@override final  DateTime time;
@override final  double hz;
@override final  int midiNote;
@override final  double clarity;
@override final  double amplitude;

/// Create a copy of TimestampedPitch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimestampedPitchCopyWith<_TimestampedPitch> get copyWith => __$TimestampedPitchCopyWithImpl<_TimestampedPitch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimestampedPitch&&(identical(other.time, time) || other.time == time)&&(identical(other.hz, hz) || other.hz == hz)&&(identical(other.midiNote, midiNote) || other.midiNote == midiNote)&&(identical(other.clarity, clarity) || other.clarity == clarity)&&(identical(other.amplitude, amplitude) || other.amplitude == amplitude));
}


@override
int get hashCode => Object.hash(runtimeType,time,hz,midiNote,clarity,amplitude);

@override
String toString() {
  return 'TimestampedPitch(time: $time, hz: $hz, midiNote: $midiNote, clarity: $clarity, amplitude: $amplitude)';
}


}

/// @nodoc
abstract mixin class _$TimestampedPitchCopyWith<$Res> implements $TimestampedPitchCopyWith<$Res> {
  factory _$TimestampedPitchCopyWith(_TimestampedPitch value, $Res Function(_TimestampedPitch) _then) = __$TimestampedPitchCopyWithImpl;
@override @useResult
$Res call({
 DateTime time, double hz, int midiNote, double clarity, double amplitude
});




}
/// @nodoc
class __$TimestampedPitchCopyWithImpl<$Res>
    implements _$TimestampedPitchCopyWith<$Res> {
  __$TimestampedPitchCopyWithImpl(this._self, this._then);

  final _TimestampedPitch _self;
  final $Res Function(_TimestampedPitch) _then;

/// Create a copy of TimestampedPitch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? hz = null,Object? midiNote = null,Object? clarity = null,Object? amplitude = null,}) {
  return _then(_TimestampedPitch(
null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,hz: null == hz ? _self.hz : hz // ignore: cast_nullable_to_non_nullable
as double,midiNote: null == midiNote ? _self.midiNote : midiNote // ignore: cast_nullable_to_non_nullable
as int,clarity: null == clarity ? _self.clarity : clarity // ignore: cast_nullable_to_non_nullable
as double,amplitude: null == amplitude ? _self.amplitude : amplitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$PitchState {

 bool get isRecording; bool get isAnalyzing; LivePitch? get currentPitch; List<TimestampedPitch> get history; List<NoteEvent> get analysisResults; String? get errorMessage; double get visibleTimeWindow; String? get currentFilePath; double get monitoringVolume; bool get isAccompanimentEnabled; String? get accompanimentPath; bool get isAecEnabled;
/// Create a copy of PitchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PitchStateCopyWith<PitchState> get copyWith => _$PitchStateCopyWithImpl<PitchState>(this as PitchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PitchState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isAnalyzing, isAnalyzing) || other.isAnalyzing == isAnalyzing)&&(identical(other.currentPitch, currentPitch) || other.currentPitch == currentPitch)&&const DeepCollectionEquality().equals(other.history, history)&&const DeepCollectionEquality().equals(other.analysisResults, analysisResults)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.visibleTimeWindow, visibleTimeWindow) || other.visibleTimeWindow == visibleTimeWindow)&&(identical(other.currentFilePath, currentFilePath) || other.currentFilePath == currentFilePath)&&(identical(other.monitoringVolume, monitoringVolume) || other.monitoringVolume == monitoringVolume)&&(identical(other.isAccompanimentEnabled, isAccompanimentEnabled) || other.isAccompanimentEnabled == isAccompanimentEnabled)&&(identical(other.accompanimentPath, accompanimentPath) || other.accompanimentPath == accompanimentPath)&&(identical(other.isAecEnabled, isAecEnabled) || other.isAecEnabled == isAecEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isRecording,isAnalyzing,currentPitch,const DeepCollectionEquality().hash(history),const DeepCollectionEquality().hash(analysisResults),errorMessage,visibleTimeWindow,currentFilePath,monitoringVolume,isAccompanimentEnabled,accompanimentPath,isAecEnabled);

@override
String toString() {
  return 'PitchState(isRecording: $isRecording, isAnalyzing: $isAnalyzing, currentPitch: $currentPitch, history: $history, analysisResults: $analysisResults, errorMessage: $errorMessage, visibleTimeWindow: $visibleTimeWindow, currentFilePath: $currentFilePath, monitoringVolume: $monitoringVolume, isAccompanimentEnabled: $isAccompanimentEnabled, accompanimentPath: $accompanimentPath, isAecEnabled: $isAecEnabled)';
}


}

/// @nodoc
abstract mixin class $PitchStateCopyWith<$Res>  {
  factory $PitchStateCopyWith(PitchState value, $Res Function(PitchState) _then) = _$PitchStateCopyWithImpl;
@useResult
$Res call({
 bool isRecording, bool isAnalyzing, LivePitch? currentPitch, List<TimestampedPitch> history, List<NoteEvent> analysisResults, String? errorMessage, double visibleTimeWindow, String? currentFilePath, double monitoringVolume, bool isAccompanimentEnabled, String? accompanimentPath, bool isAecEnabled
});




}
/// @nodoc
class _$PitchStateCopyWithImpl<$Res>
    implements $PitchStateCopyWith<$Res> {
  _$PitchStateCopyWithImpl(this._self, this._then);

  final PitchState _self;
  final $Res Function(PitchState) _then;

/// Create a copy of PitchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRecording = null,Object? isAnalyzing = null,Object? currentPitch = freezed,Object? history = null,Object? analysisResults = null,Object? errorMessage = freezed,Object? visibleTimeWindow = null,Object? currentFilePath = freezed,Object? monitoringVolume = null,Object? isAccompanimentEnabled = null,Object? accompanimentPath = freezed,Object? isAecEnabled = null,}) {
  return _then(_self.copyWith(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isAnalyzing: null == isAnalyzing ? _self.isAnalyzing : isAnalyzing // ignore: cast_nullable_to_non_nullable
as bool,currentPitch: freezed == currentPitch ? _self.currentPitch : currentPitch // ignore: cast_nullable_to_non_nullable
as LivePitch?,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<TimestampedPitch>,analysisResults: null == analysisResults ? _self.analysisResults : analysisResults // ignore: cast_nullable_to_non_nullable
as List<NoteEvent>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,visibleTimeWindow: null == visibleTimeWindow ? _self.visibleTimeWindow : visibleTimeWindow // ignore: cast_nullable_to_non_nullable
as double,currentFilePath: freezed == currentFilePath ? _self.currentFilePath : currentFilePath // ignore: cast_nullable_to_non_nullable
as String?,monitoringVolume: null == monitoringVolume ? _self.monitoringVolume : monitoringVolume // ignore: cast_nullable_to_non_nullable
as double,isAccompanimentEnabled: null == isAccompanimentEnabled ? _self.isAccompanimentEnabled : isAccompanimentEnabled // ignore: cast_nullable_to_non_nullable
as bool,accompanimentPath: freezed == accompanimentPath ? _self.accompanimentPath : accompanimentPath // ignore: cast_nullable_to_non_nullable
as String?,isAecEnabled: null == isAecEnabled ? _self.isAecEnabled : isAecEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PitchState].
extension PitchStatePatterns on PitchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PitchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PitchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PitchState value)  $default,){
final _that = this;
switch (_that) {
case _PitchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PitchState value)?  $default,){
final _that = this;
switch (_that) {
case _PitchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRecording,  bool isAnalyzing,  LivePitch? currentPitch,  List<TimestampedPitch> history,  List<NoteEvent> analysisResults,  String? errorMessage,  double visibleTimeWindow,  String? currentFilePath,  double monitoringVolume,  bool isAccompanimentEnabled,  String? accompanimentPath,  bool isAecEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PitchState() when $default != null:
return $default(_that.isRecording,_that.isAnalyzing,_that.currentPitch,_that.history,_that.analysisResults,_that.errorMessage,_that.visibleTimeWindow,_that.currentFilePath,_that.monitoringVolume,_that.isAccompanimentEnabled,_that.accompanimentPath,_that.isAecEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRecording,  bool isAnalyzing,  LivePitch? currentPitch,  List<TimestampedPitch> history,  List<NoteEvent> analysisResults,  String? errorMessage,  double visibleTimeWindow,  String? currentFilePath,  double monitoringVolume,  bool isAccompanimentEnabled,  String? accompanimentPath,  bool isAecEnabled)  $default,) {final _that = this;
switch (_that) {
case _PitchState():
return $default(_that.isRecording,_that.isAnalyzing,_that.currentPitch,_that.history,_that.analysisResults,_that.errorMessage,_that.visibleTimeWindow,_that.currentFilePath,_that.monitoringVolume,_that.isAccompanimentEnabled,_that.accompanimentPath,_that.isAecEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRecording,  bool isAnalyzing,  LivePitch? currentPitch,  List<TimestampedPitch> history,  List<NoteEvent> analysisResults,  String? errorMessage,  double visibleTimeWindow,  String? currentFilePath,  double monitoringVolume,  bool isAccompanimentEnabled,  String? accompanimentPath,  bool isAecEnabled)?  $default,) {final _that = this;
switch (_that) {
case _PitchState() when $default != null:
return $default(_that.isRecording,_that.isAnalyzing,_that.currentPitch,_that.history,_that.analysisResults,_that.errorMessage,_that.visibleTimeWindow,_that.currentFilePath,_that.monitoringVolume,_that.isAccompanimentEnabled,_that.accompanimentPath,_that.isAecEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _PitchState implements PitchState {
  const _PitchState({this.isRecording = false, this.isAnalyzing = false, this.currentPitch, final  List<TimestampedPitch> history = const [], final  List<NoteEvent> analysisResults = const [], this.errorMessage, this.visibleTimeWindow = 5.0, this.currentFilePath, this.monitoringVolume = 0.0, this.isAccompanimentEnabled = false, this.accompanimentPath, this.isAecEnabled = false}): _history = history,_analysisResults = analysisResults;
  

@override@JsonKey() final  bool isRecording;
@override@JsonKey() final  bool isAnalyzing;
@override final  LivePitch? currentPitch;
 final  List<TimestampedPitch> _history;
@override@JsonKey() List<TimestampedPitch> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

 final  List<NoteEvent> _analysisResults;
@override@JsonKey() List<NoteEvent> get analysisResults {
  if (_analysisResults is EqualUnmodifiableListView) return _analysisResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_analysisResults);
}

@override final  String? errorMessage;
@override@JsonKey() final  double visibleTimeWindow;
@override final  String? currentFilePath;
@override@JsonKey() final  double monitoringVolume;
@override@JsonKey() final  bool isAccompanimentEnabled;
@override final  String? accompanimentPath;
@override@JsonKey() final  bool isAecEnabled;

/// Create a copy of PitchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PitchStateCopyWith<_PitchState> get copyWith => __$PitchStateCopyWithImpl<_PitchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PitchState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isAnalyzing, isAnalyzing) || other.isAnalyzing == isAnalyzing)&&(identical(other.currentPitch, currentPitch) || other.currentPitch == currentPitch)&&const DeepCollectionEquality().equals(other._history, _history)&&const DeepCollectionEquality().equals(other._analysisResults, _analysisResults)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.visibleTimeWindow, visibleTimeWindow) || other.visibleTimeWindow == visibleTimeWindow)&&(identical(other.currentFilePath, currentFilePath) || other.currentFilePath == currentFilePath)&&(identical(other.monitoringVolume, monitoringVolume) || other.monitoringVolume == monitoringVolume)&&(identical(other.isAccompanimentEnabled, isAccompanimentEnabled) || other.isAccompanimentEnabled == isAccompanimentEnabled)&&(identical(other.accompanimentPath, accompanimentPath) || other.accompanimentPath == accompanimentPath)&&(identical(other.isAecEnabled, isAecEnabled) || other.isAecEnabled == isAecEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isRecording,isAnalyzing,currentPitch,const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_analysisResults),errorMessage,visibleTimeWindow,currentFilePath,monitoringVolume,isAccompanimentEnabled,accompanimentPath,isAecEnabled);

@override
String toString() {
  return 'PitchState(isRecording: $isRecording, isAnalyzing: $isAnalyzing, currentPitch: $currentPitch, history: $history, analysisResults: $analysisResults, errorMessage: $errorMessage, visibleTimeWindow: $visibleTimeWindow, currentFilePath: $currentFilePath, monitoringVolume: $monitoringVolume, isAccompanimentEnabled: $isAccompanimentEnabled, accompanimentPath: $accompanimentPath, isAecEnabled: $isAecEnabled)';
}


}

/// @nodoc
abstract mixin class _$PitchStateCopyWith<$Res> implements $PitchStateCopyWith<$Res> {
  factory _$PitchStateCopyWith(_PitchState value, $Res Function(_PitchState) _then) = __$PitchStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRecording, bool isAnalyzing, LivePitch? currentPitch, List<TimestampedPitch> history, List<NoteEvent> analysisResults, String? errorMessage, double visibleTimeWindow, String? currentFilePath, double monitoringVolume, bool isAccompanimentEnabled, String? accompanimentPath, bool isAecEnabled
});




}
/// @nodoc
class __$PitchStateCopyWithImpl<$Res>
    implements _$PitchStateCopyWith<$Res> {
  __$PitchStateCopyWithImpl(this._self, this._then);

  final _PitchState _self;
  final $Res Function(_PitchState) _then;

/// Create a copy of PitchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRecording = null,Object? isAnalyzing = null,Object? currentPitch = freezed,Object? history = null,Object? analysisResults = null,Object? errorMessage = freezed,Object? visibleTimeWindow = null,Object? currentFilePath = freezed,Object? monitoringVolume = null,Object? isAccompanimentEnabled = null,Object? accompanimentPath = freezed,Object? isAecEnabled = null,}) {
  return _then(_PitchState(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isAnalyzing: null == isAnalyzing ? _self.isAnalyzing : isAnalyzing // ignore: cast_nullable_to_non_nullable
as bool,currentPitch: freezed == currentPitch ? _self.currentPitch : currentPitch // ignore: cast_nullable_to_non_nullable
as LivePitch?,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<TimestampedPitch>,analysisResults: null == analysisResults ? _self._analysisResults : analysisResults // ignore: cast_nullable_to_non_nullable
as List<NoteEvent>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,visibleTimeWindow: null == visibleTimeWindow ? _self.visibleTimeWindow : visibleTimeWindow // ignore: cast_nullable_to_non_nullable
as double,currentFilePath: freezed == currentFilePath ? _self.currentFilePath : currentFilePath // ignore: cast_nullable_to_non_nullable
as String?,monitoringVolume: null == monitoringVolume ? _self.monitoringVolume : monitoringVolume // ignore: cast_nullable_to_non_nullable
as double,isAccompanimentEnabled: null == isAccompanimentEnabled ? _self.isAccompanimentEnabled : isAccompanimentEnabled // ignore: cast_nullable_to_non_nullable
as bool,accompanimentPath: freezed == accompanimentPath ? _self.accompanimentPath : accompanimentPath // ignore: cast_nullable_to_non_nullable
as String?,isAecEnabled: null == isAecEnabled ? _self.isAecEnabled : isAecEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
