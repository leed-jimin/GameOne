extends Node

const X509CertFilename = "x509_Certificate.crt"
const X509KeyFilename = "x509_Key.key"
const directoryPath = "res://certificate/"
onready var X509CertPath = directoryPath + X509CertFilename
onready var X509KeyPath = directoryPath + X509KeyFilename

const CN = "GameOne" #domain name
const O = "DaKneelee" #organization
const C = "AA" #country code letter ISO-3166
const notBefore = "20210424000000"
const notAfter = "20220424000000"

func _ready():
	var directory = Directory.new()
	if not directory.dir_exists(directoryPath):
		directory.make_dir(directoryPath)
	create_X509_cert()
	print("Certification created")
	
func create_X509_cert():
	var CNOC = "CN={0},O={1},C={2}".format({"0": CN, "1": O, "2": C})
	var crypto = Crypto.new()
	var cryptoKey = crypto.generate_rsa(4096)
	var x509Cert = crypto.generate_self_signed_certificate(cryptoKey, CNOC, notBefore, notAfter)
	
	x509Cert.save(X509CertPath)
	cryptoKey.save(X509KeyPath)
