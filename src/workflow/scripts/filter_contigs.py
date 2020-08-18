from Bio import SeqIO
from Bio.Seq import Seq
import fire

def filter_fasta(input_fasta, sample_name, min_length):
    for record in SeqIO.parse(input_fasta, "fasta"):
        if len(record) >= min_length:
            new_name= record.name.replace("NODE", f'{sample_name}')
            new_name = new_name.replace("length", "l").replace("cov", "c")
            print(">" + new_name)
            print(record.seq)

if __name__ == '__main__':
    fire.Fire(filter_fasta)
