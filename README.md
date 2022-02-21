前提摘要：该自动化测试框架主要是由robotframework + python 构成；上层由RF构建自动化case，底层由python编写具体功能的函数；最后由这些函数（RF中叫关键字）构建成具体的自动化测试用例。

目前测试圈主要流行的测试框架有unittest，pytest，robotframework等等，个人觉得三者各有优劣，不好评价谁好谁坏；但是我个人觉得目前python + robotframework的方式是最优的方案，但是前提要具备python编码能力。因为python + RF的模式能够让测试更加灵活，在底层实现任意你想要的功能，在上层RF中用函数构建用例也更加灵活且易读。

在RF中构建测试用例，首先RF类似于Excel，条目清晰，可读性佳，且上手容易，对于手动测试的同学也可快速上手编写测试用例。这样一来，自动化的同学只需关注底层函数的编写。其次，RF中已经集成了很多优秀的功能，比如失败重跑，给测试用例打标签，可以利用标签来决定执行哪些用例。还有，在RF中用例的执行也更加容易，直接勾选想运行的case点击start即可。最后，RF中测试用例执行完璧后可生成详细的测试log和清晰的测试报告，详细的测试log可帮助自动化测试同学更好的定位问题所在，提高开发效率。

由于我们目前用的这套测试框架内容比较多，且由于项目保密需要我将很多项目内容做了删除，但是框架是完整的。为了更清晰的展示框架结构，我画了一张思维导图：
![image](https://github.com/xgh321324/TA-Environment/blob/xgh321324-patch-1/%E6%A1%86%E6%9E%B6%E7%BB%93%E6%9E%84%E5%9B%BE.jpg)

最后的最后，如果大家有疑问，欢迎加QQ：970185127 一起讨论，互相学习！

