library streamy.generator.emitter.test;

import 'package:streamy/generator.dart';
import 'package:unittest/unittest.dart';
import '../project.dart';

main(List<String> args) {
  var discovery = new Discovery.fromJsonString(
"""
{
  "name": "DocsTest",
  "description": "API definitions.\\nWith documentation",
  "servicePath": "docsTest/v1/",
  "schemas": {
    "Foo": {
      "id": "Foo",
      "type": "object",
      "description": "This is a foo.\\nEnough said.",
      "properties": {
        "id": {
          "type": "integer",
          "description": "Primary key.\\nSometimes called ID."
        }
      }
    }
  },
  "resources": {
    "foos": {
      "methods": {
        "get": {
          "id": "service.foos.get",
          "path": "foos/{fooId}",
          "name": "",
          "response": {
            "\$ref": "Foo"
          },
          "httpMethod": "GET",
          "description": "Gets a foo.\\nReturns 404 on bad ID.",
          "parameters": {
            "fooId": {
              "type": "integer",
              "description": "Primary key of foo.\\nSecond line",
              "required": true,
              "location": "path"
            }
          },
          "parameterOrder": ["fooId"]
        }
      }
    }
  }
}
""");

  var rootOut = new StringBuffer();
  var resourceOut = new StringBuffer();
  var requestOut = new StringBuffer();
  var objectOut = new StringBuffer();
  emitCode(new EmitterConfig(
      discovery,
      new DefaultTemplateProvider('${projectRootDir(args)}/templates'),
      rootOut,
      resourceOut,
      requestOut,
      objectOut,
      addendumData: const {
        'lib_name': 'docstestapi',
      }));

  var rootCode = rootOut.toString();
  var resourceCode = resourceOut.toString();
  var requestCode = requestOut.toString();
  var objectCode = objectOut.toString();

  group('Emitter', () {
    test('should emit docs for root class', () {
      expectContains(rootCode,
          '/// API definitions.\n'
          '/// With documentation\n'
          'class DocsTest\n');
    });
    test('should emit docs for resource methods', () {
      expectContains(resourceCode,
          '  /// Gets a foo.\n'
          '  /// Returns 404 on bad ID.\n'
          '  req.FoosGetRequest get(');
    });
    test('should emit docs for request class', () {
      expectContains(requestCode,
          '/// Gets a foo.\n'
          '/// Returns 404 on bad ID.\n'
          'class FoosGetRequest ');
    });
    test('should emit docs for request parameter', () {
      expectContains(requestCode,
          '  /// Primary key of foo.\n'
          '  /// Second line\n'
          '  int get fooId =>');
    });
    test('should emit docs for schema class', () {
      expectContains(objectCode,
          '/// This is a foo.\n'
          '/// Enough said.\n'
          'class Foo ');
    });
    test('should emit docs for schema property', () {
      expectContains(objectCode,
          '  /// Primary key.\n'
          '  /// Sometimes called ID.\n'
          '  int get id => ');
    });
  });
}

void expectContains(String container, String containee) {
  expect(container.contains(containee), isTrue,
      reason: "'$container' does not contain '$containee'");
}
