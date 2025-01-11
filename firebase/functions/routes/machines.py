from flask import Blueprint, jsonify, request, Response
from decorators import token_required
from controllers.machines import load_file, reset, write, read

bp = Blueprint('api_machines', __name__)

@bp.route('/load-file', methods=['POST'])
@token_required
def load_file_route():
    if 'file' not in request.files:
        return Response(status=400, response="No file part in the request.")

    file = request.files['file']
    if file.filename == '':
        return Response(status=400, response="No file selected.")

    if not file.filename.endswith('.csv'):
        return Response(status=400, response="Only CSV files are allowed.")
    
    machine = request.form.get('machine').lower().strip()
    if not machine or machine not in ["incartonatrice", "confezionatrice"]:
        return jsonify({"message": "Invalid or missing 'machine' parameter. Allowed values are 'Incartonatrice' or 'Confezionatrice'."}, 401)

    return load_file(file, machine)


@bp.route('/reset', methods=['DELETE'])
@token_required
def reset_route():
    return reset()


@bp.route('/write', methods=['POST'])
@token_required
def write_route():
    data = request.get_json()

    machine = data.get('machine', '').lower().strip()
    lotto = data.get('lotto', '').strip()
    codice_prodotto = data.get('codiceProdotto', '').strip()
    codice_ricetta = data.get('codiceRicetta', '')

    if not machine or not lotto or not codice_prodotto or not codice_ricetta:
        return jsonify({'error': 'Missing required fields'}), 400
    
    document_data = {
        'lotto': lotto,
        'codiceProdotto': codice_prodotto,
        'codiceRicetta': codice_ricetta
    }
    
    return write(machine, document_data)


@bp.route('/read/<string:machine>/<int:index>', methods=['GET'])
@token_required
def get_document(machine, index):
    machine = str(machine.lower().strip())
    index = int(index)
    return read(machine, index)