use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use File::Spec::Functions;
use Mojolicious::Lite;
use lib 't/lib';

plugin Swagger2 => {url => 'data://main/petstore.json'};
app->routes->namespaces(['MyApp::Controller']);

my $t = Test::Mojo->new;

$MyApp::Controller::Pet::RES = [{id => 123, name => 'kit-cat'}];
$t->get_ok('/api/pets')->status_is(200)->json_is('/0/id', 123)->json_is('/0/name', 'kit-cat');

$MyApp::Controller::Pet::RES = {name => 'kit-cat'};
$t->post_ok('/api/pets/42')->status_is(200)->json_is('/id', 42)->json_is('/name', 'kit-cat');

done_testing;

__DATA__
@@ petstore.json
{
  "swagger": "2.0",
  "info": { "version": "1.0.0", "title": "Swagger Petstore" },
  "basePath": "/api",
  "parameters": {
    "limit": {
      "name": "limit",
      "in": "query",
      "description": "How many items to return at one time (max 100)",
      "type": "integer",
      "format": "int32"
    }
  },
  "paths": {
    "/pets": {
      "get": {
        "summary": "finds pets in the system",
        "operationId": "listPets",
        "parameters": [ { "$ref": "#/parameters/limit" } ],
        "responses": {
          "200": {
            "description": "pet response",
            "schema": { "type": "array", "items": { "$ref": "#/definitions/Pet" } }
          },
          "default": {
            "description": "unexpected error",
            "schema": { "$ref": "https://raw.githubusercontent.com/jhthorsen/swagger2/master/lib/Swagger2/error.json" }
          }
        }
      },
      "post": {
        "summary": "add pets to the system",
        "operationId": "addPet",
        "parameters": [
          {
            "name": "data",
            "in": "body",
            "required": true,
            "schema": {
              "type": "object",
              "properties": { "name": { "type": "string" }, "tag": { "type": "string" } }
            }
          }
        ],
        "responses": {
          "200": { "description": "pet response", "schema": { "$ref": "#/definitions/Pet" } },
          "default": { "description": "unexpected error", "schema": { "$ref": "http://git.io/vcKD4#" } }
        }
      }
    },
    "/pets/{petId}": {
      "post": {
        "summary": "Info for a specific pet",
        "operationId": "showPetById",
        "parameters": [
          {
            "name": "petId",
            "in": "path",
            "required": true,
            "description": "The id of the pet to receive",
            "type": "integer"
          }
        ],
        "responses": {
          "200": { "description": "Expected response to a valid request", "schema": { "$ref": "#/definitions/Pet" } },
          "default": { "description": "unexpected error", "schema": { "$ref": "http://git.io/vcKD4#" } }
        }
      }
    }
  },
  "definitions": {
    "Pet": {
      "required": [ "id", "name" ],
      "properties": {
        "id": { "type": "integer", "format": "int64" },
        "name": { "type": "string" },
        "tag": { "type": "string" }
      }
    }
  }
}
