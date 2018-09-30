from hid import RFIDReader
from util import FIFOReader

url = 'https://api.padmiss.com/'
apikey = '{{ padmiss_api_key }}'
scores_dir = '/home/stepmania/.stepmania-5.1/Save/Padmiss'
backup_dir = '/opt/padmiss-daemon-backups'
profile_dir = 'StepMania 5'

readers = {
    '/tmp/padmiss-daemon-p1' : lambda: RFIDReader(idVendor=0x08ff, idProduct=0x0009, bus={{ rfid_reader_p1_bus }}, port_number={{ rfid_reader_p1_port_number }}),
    '/tmp/padmiss-daemon-p2' : lambda: RFIDReader(idVendor=0x08ff, idProduct=0x0009, bus={{ rfid_reader_p2_bus }}, port_number={{ rfid_reader_p2_port_number }}),
}
