from Bio import SeqIO
from Bio.Seq import Seq
import fire

def filter_fasta(input_fasta, sample_name, min_length):
    for record in SeqIO.parse(input_fasta, "fasta"):
        if len(record) >= min_length:
            record.id = record.name.replace("NODE", f'{sample_name}' + "_scf")\
                .replace("_length", " length").replace("scf_", "scf")
            print(record.format("fasta"), end="")

if __name__ == '__main__':
    fire.Fire(filter_fasta)
