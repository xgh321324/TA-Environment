import io
import pathlib
import re
import shutil

if __name__ == '__main__':
	robotFiles = pathlib.Path('.').glob('./**/*.robot')

	forPattern = re.compile(r'^ {4}: ?FOR', re.I)
	forBodyPattern = re.compile(r'^ {4}\\')
	forHeaderContinuePattern = re.compile(r'^ {4}\.\.\.')

	for rFile in robotFiles:
		print('Processing {!s}'.format(rFile))

		newFile = io.StringIO()
		forLoopCounter = 0

		with open(rFile, 'r', encoding='utf-8') as rf:
			inForLoop = False
			forHeaderDone = False

			for l in rf:
				if not inForLoop:
					m = forPattern.search(l)

					if m:
						forLoopCounter += 1
						inForLoop = True
						forHeaderDone = False
						l = '    FOR' + l[m.end():]
				else:
					if not forHeaderDone:
						if forHeaderContinuePattern.search(l):
							newFile.write(l)
							continue
						else:
							forHeaderDone = True

					m = forBodyPattern.search(l)

					if m:
						l = '    ' + l[m.end():]
					else:
						inForLoop = False

						m2 = forPattern.search(l)

						if m2:
							forLoopCounter += 1
							inForLoop = True
							forHeaderDone = False
							l = '    FOR' + l[m2.end():]

						l = '    END\n' + l

				newFile.write(l)

		print('Handled {:d} for loops'.format(forLoopCounter))

		if forLoopCounter > 0:
			print('Writing processed file to disk')

			newFile.seek(0)

			with open(rFile, 'w', encoding='utf-8') as rf:
				shutil.copyfileobj(newFile, rf)
		else:
			print('Skip writing due to no for loops found in this file')

		print('')
