import itertools
import multiprocessing
import pathlib
import re

def find_keywords(root='./', pattern='./**/*.robot'):
	keywords = []
	keywordRegex = re.compile(r'^\S+?\s*?$')
	keywordSepRegex = re.compile(r' |_')

	for f in pathlib.Path(root).glob(pattern):
		inKeywords = False

		with open(f, 'r', encoding='utf-8') as rf:
			rfPath = str(f.absolute())

			for l in rf:
				ls = l.strip()

				if inKeywords and ls[:3] == '***':
					inKeywords = False
					break

				if ls.lower() == '*** keywords ***':
					inKeywords = True
					continue

				if inKeywords and keywordRegex.match(l):
					keywords.append({
						'keyword': ls,
						'pattern': re.compile(r'.' + r'( |_)?'.join(re.split(keywordSepRegex, re.escape(ls))), re.I),
						'source': rfPath,
					})

	return keywords

def _keyword_usage_finder(file, keywords):
	foundKeywords = []

	with open(file, 'r', encoding='utf-8') as rf:
		for l in rf:
			for k in keywords:
				if re.search(k['pattern'], l):
					foundKeywords.append({
						'keyword': k['keyword'],
						'source': k['source'],
					})

	return foundKeywords

def find_keywords_usage(keywords, root='./', pattern='./**/*.robot'):
	keywordFindData = {
		'derp': {
			'files': [
				'',
				'',
			],
		},
	}
	keywordFindData = {}

	with multiprocessing.Pool() as pool:
		fileList = pathlib.Path(root).glob(pattern)
		keywordFindDataList = pool.starmap(_keyword_usage_finder, zip(fileList, itertools.repeat(keywords)), 3)
		allKeywordsFound = set(kw['keyword'] for kw in itertools.chain.from_iterable(keywordFindDataList))

		for keyword in allKeywordsFound:
			keywordFindData[keyword] = {
				'source': '',
				'files': [],
			}

		for f, foundKeywords in zip(fileList, keywordFindDataList):
			for k in foundKeywords:
				keywordFindData[k['keyword']]['source'] = k['source']
				keywordFindData[k['keyword']]['files'].append(f)

	return keywordFindData

if __name__ == '__main__':
	foundKeywords = find_keywords()

	print('Total Keywords\t{:d}'.format(len(foundKeywords)))

	usedKeywords = find_keywords_usage(foundKeywords)
	unusedKeywords = set(k['keyword'] for k in foundKeywords) - set(usedKeywords)

	print('Unused Keywords\t{:d}'.format(len(unusedKeywords)))
	print('')

	unusedKeywords = itertools.groupby(
		sorted(
			filter(
				lambda fk: fk['keyword'] in unusedKeywords,
				foundKeywords
			),
			key=lambda uk: uk['source'].lower(),
		),
		key=lambda uk: uk['source'].lower(),
	)

	for source, keywords in unusedKeywords:
		print(source)
		print('\t' + '\n\t'.join(kw['keyword'] for kw in keywords))
		print('')
