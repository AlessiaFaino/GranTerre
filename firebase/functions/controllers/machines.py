from firebase_admin import firestore
import pandas as pd
from flask import jsonify
from datetime import datetime


def load_file(file, machine):
    try:
        db = firestore.client()
        df = pd.read_csv(file, delimiter=';')
        records = df.to_dict(orient='records')
        for i, record in enumerate(records):
            start_time = datetime.strptime(record.get('StartTime', ''), '%Y-%m-%d %H:%M:%S.%f')
            stop_time = datetime.strptime(record.get('StopTime', ''), '%Y-%m-%d %H:%M:%S.%f')
            document_data = {
                "index": int(i),
                'StartTime': start_time.timestamp(),
                'StopTime': stop_time.timestamp(),
                'OrdineDiLavoro': str(record.get('OrdineDiLavoro', '')),
                'Lotto': str(record.get('Lotto', '')),
                'CodiceProdotto': str(record.get('CodiceProdotto', '')),
                'CodiceRicettaUtilizzata': int(record.get('CodiceRicettaUtilizzata', -1)),
                'NumeroConfezioni': int(record.get('NumeroConfezioni', -1)),
                'VelocitaMedia': int(record.get('VelocitàMedia [BPM]', -1)),
                'CentroLavoro': str(record.get('Centro_Lavoro', '')),
                'Status': int(record.get('Status', -1)),
                'LottoRichiesto': str(record.get('LottoRichiesto', '')),
                'CodiceProdottoRichiesto': str(record.get('CodiceProdottoRichiesto', '')),
                'CodiceRicettaRichiesta': int(record.get('CodiceRicettaRichiesta', -1)),
            }

            db.collection(machine).add(document_data)

        return jsonify({'message': 'CSV processed and data added successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

def reset():
    try:
        db = firestore.client()
        for machine in ["incartonatrice", "confezionatrice"]:
            machines_ref = db.collection(machine)
            docs = machines_ref.stream()
            for doc in docs:
                machines_ref.document(doc.id).delete()

        return jsonify({'message': 'Machines collection has been reset.'}), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

def write(machine, document_data):
    try:
        db = firestore.client()
        db.collection(machine).add(document_data)
        return jsonify({'message': 'Machine data added successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

def read(machine, index):
    try:
        db = firestore.client()
        documents = db.collection(machine).where("index", '==', index).get()
        if not documents or len(documents) == 0: return jsonify({"success": False, "message": str(e)}), 500
        document = documents[0]
        if document and document.exists:
            return jsonify({"success": True, "data": document.to_dict()}), 200
        else:
            return jsonify({"success": False, "message": "Document not found"}), 404
        
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500