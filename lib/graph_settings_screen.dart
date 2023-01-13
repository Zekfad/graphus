import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:math_parser/math_parser.dart';
import 'package:reactive_color_picker/reactive_color_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'graph.dart';


class MathValidator extends Validator<dynamic> {
  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final error = <String, dynamic>{'bad_math': true};

    if (control.value is! String || control.value == null) {
      return error;
    } else {
      final value = (control.value as String).trim();
      try {
        final expression = MathNodeExpression.fromString(value);
        final vars = expression.getUsedVariables();
        if (!vars.contains('x') || vars.length != 1)
          return error;
      } on MathException {
        return error;
      }
    }
  }
}


class GraphSettingsScreen extends StatefulWidget {
  const GraphSettingsScreen({
    required this.callback,
    this.initialData,
    super.key,
  });


  final GraphData? initialData;
  final void Function(GraphData data) callback;

  @override
  State<GraphSettingsScreen> createState() => _GraphSettingsScreenState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GraphData?>('initialData', initialData))
      ..add(ObjectFlagProperty<void Function(GraphData data)>.has('callback', callback));
  }
}

class _GraphSettingsScreenState extends State<GraphSettingsScreen> {
  GraphData? get initial => widget.initialData;

  late GraphData data = initial ?? const GraphData(
    series: [],
    scales: [],
    min: 0,
    max: 10,
  );

  final seriesFormArray = FormArray([]);
  final scalesFormArray = FormArray([]);

  late final form = FormGroup({
    'min': FormControl<double>(value: data.min, validators: [Validators.required]),
    'max': FormControl<double>(value: data.max, validators: [Validators.required]),
    'leftScale': FormControl<int>(value: data.leftScale ?? 0, validators: [Validators.required]),
    'rightScale': FormControl<int>(value: data.rightScale),
    'series': seriesFormArray,
    'scales': scalesFormArray,
  });

  FormGroup createSeriesFormGroup(Series? series) =>
    FormGroup({
      'from': FormControl<double>(value: series?.source?.from ?? 0, validators: [Validators.required]),
      'to': FormControl<double>(value: series?.source?.to ?? 10, validators: [Validators.required]),
      'step': FormControl<double>(value: series?.source?.step ?? 1, validators: [Validators.required]),
      'function': FormControl<String>(value: series?.source?.function ?? 'x', validators: [
        Validators.required,
        MathValidator().validate,
      ],),
      'scaleIndex': FormControl<int>(value: series?.scaleIndex ?? 0, validators: [Validators.required]),
      'smoothFactor': FormControl<double>(value: series?.smoothFactor ?? 0.5, validators: [Validators.required]),
      'color': FormControl<Color>(value: series?.paint.color ?? Colors.black, validators: [Validators.required]),
    },
  );

  FormGroup createLinearScaleFormGroup(LinearScale? scale) =>
    FormGroup({
      'min': FormControl<double>(value: scale?.min ?? 0, validators: [Validators.required]),
      'max': FormControl<double>(value: scale?.max ?? 10, validators: [Validators.required]),
    });

  @override
  void initState() {
    for (final series in data.series)
      seriesFormArray.add(createSeriesFormGroup(series));
    for (final scale in data.scales)
      scalesFormArray.add(createLinearScaleFormGroup(scale as LinearScale));
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: ReactiveFormConfig(
          validationMessages: {
            ValidationMessage.required: (error) => 'Field must be valid',
            'bad_math': (error) => 'Bad math expression',
          },
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              children: [
                Text('Plot config:', style: Theme.of(context).textTheme.headlineMedium),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: ReactiveTextField<double>(
                        formControlName: 'min',
                        decoration: const InputDecoration(
                          labelText: 'Viewport minimum X value',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: ReactiveTextField<double>(
                        formControlName: 'max',
                        decoration: const InputDecoration(
                          labelText: 'Viewport maximum X value',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: ReactiveTextField<int>(
                        formControlName: 'leftScale',
                        decoration: const InputDecoration(
                          labelText: 'Left scale',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: ReactiveTextField<int>(
                        formControlName: 'rightScale',
                        decoration: const InputDecoration(
                          labelText: 'Right scale',
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Controls:', style: Theme.of(context).textTheme.headlineMedium),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Scales controls:'),
                      ElevatedButton(
                        child: const Text('Add scale (+)'),
                        onPressed: () {
                          scalesFormArray.add(createLinearScaleFormGroup(null));
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Remove scale (-)'),
                        onPressed: () {
                          if (scalesFormArray.controls.isNotEmpty)
                            scalesFormArray.remove(scalesFormArray.controls.last);
                        },
                      ),
                      const Text('Series controls:'),
                      ElevatedButton(
                        child: const Text('Add series (+)'),
                        onPressed: () {
                          seriesFormArray.add(createSeriesFormGroup(null));
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Remove series (-)'),
                        onPressed: () {
                          if (seriesFormArray.controls.isNotEmpty)
                            seriesFormArray.remove(seriesFormArray.controls.last);
                        },
                      ),
                    ],
                  ),
                ),
                Text('Scales:', style: Theme.of(context).textTheme.headlineMedium),
                ReactiveFormArray(
                  formArrayName: 'scales',
                  builder: (context, formArray, child) => Wrap(
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < formArray.controls.length; i++)
                        ReactiveForm(
                          formGroup: formArray.controls[i] as FormGroup,
                          child: Card(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Scale $i config:', style: Theme.of(context).textTheme.headlineSmall),
                                    Flexible(
                                      child: ReactiveTextField<double>(
                                        formControlName: 'min',
                                        decoration: const InputDecoration(
                                          labelText: 'Viewport minimum Y value',
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ReactiveTextField<double>(
                                        formControlName: 'max',
                                        decoration: const InputDecoration(
                                          labelText: 'Viewport maximum Y value',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text('Series:', style: Theme.of(context).textTheme.headlineMedium),
                ReactiveFormArray(
                  formArrayName: 'series',
                  builder: (context, formArray, child) => Wrap(
                    runSpacing: 20,
                    children: [
                      for (var i = 0; i < formArray.controls.length; i++)
                        ReactiveForm(
                          formGroup: formArray.controls[i] as FormGroup,
                          child: Card(
                            child: Column(
                              children: [
                                Text('Series $i config:', style: Theme.of(context).textTheme.headlineSmall),
                                ReactiveTextField<String>(
                                  formControlName: 'function',
                                  decoration: const InputDecoration(
                                    labelText: 'Source function',
                                  ),
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: ReactiveTextField<double>(
                                        formControlName: 'from',
                                        decoration: const InputDecoration(
                                          labelText: 'Discretization from',
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ReactiveTextField<double>(
                                        formControlName: 'to',
                                        decoration: const InputDecoration(
                                          labelText: 'Discretization to',
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ReactiveTextField<double>(
                                        formControlName: 'step',
                                        decoration: const InputDecoration(
                                          labelText: 'Discretization step',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ReactiveTextField<double>(
                                  formControlName: 'smoothFactor',
                                  decoration: const InputDecoration(
                                    labelText: 'Smooth factor',
                                  ),
                                ),
                                ReactiveTextField<int>(
                                  formControlName: 'scaleIndex',
                                  decoration: const InputDecoration(
                                    labelText: 'Scale index',
                                  ),
                                ),
                                ReactiveBlockColorPicker<Color>(
                                  formControlName: 'color',
                                  decoration: const InputDecoration(
                                    labelText: 'Color',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SubmitButton(
                  data: data,
                  callback: widget.callback,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GraphData?>('initial', initial))
      ..add(DiagnosticsProperty<GraphData>('data', data))
      ..add(DiagnosticsProperty<FormArray<Object?>>('seriesFormArray', seriesFormArray))
      ..add(DiagnosticsProperty<FormArray<Object?>>('scalesFormArray', scalesFormArray))
      ..add(DiagnosticsProperty<FormGroup>('form', form));
  }
}


class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.data,
    required this.callback,
    super.key,
  });

  final GraphData data;
  final void Function(GraphData data) callback;

  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context);
    return ElevatedButton(
      onPressed: form!.valid
        ? () async => onSubmit(context)
        : null,
      child: const Text('Submit'),
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    final form = ReactiveForm.of(context)!;
    final router = AutoRouter.of(context);
    final value = form.value! as dynamic;

    final seriesList = <Series>[];
    for (final series in value['series'] as List) {
      final seriesSource = SeriesSource(
        from: series['from'] as double,
        to: series['to'] as double,
        step: series['step'] as double,
        function: series['function'] as String,
      ); 
      seriesList.add(
        Series(
          paint: Paint()
            ..strokeWidth = 5
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round
            ..color = series['color'] as Color,
          source: seriesSource,
          points: seriesSource.discretize(),
          scaleIndex: series['scaleIndex'] as int,
          smoothFactor: series['smoothFactor'] as double,
        ),
      );
    }
    final newData = data.copyWith(
      min: value['min'] as double,
      max: value['max'] as double,
      leftScale: value['leftScale'] as int?,
      rightScale: value['rightScale'] as int?,
      series: seriesList,
      scales: [
        for (final scale in value['scales'] as List)
          LinearScale(
            scale['min'] as double,
            scale['max'] as double,
          ),
      ],
    );
    callback(newData);
    await router.pop();
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GraphData>('data', data))
      ..add(ObjectFlagProperty<void Function(GraphData data)>.has('callback', callback));
  }
}
