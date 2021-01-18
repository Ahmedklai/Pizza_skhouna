import 'package:flutter/material.dart';
import 'ingrediant.dart';

const _buttonSize = 48.0;

class PizzaOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Pizza Skhouna '),
        actions: [
          IconButton(
              icon: Icon(
                Icons.add_shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {})
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
              bottom: 50,
              left: 10,
              right: 10,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                child: Column(
                  children: [
                    Expanded(flex: 3, child: _PizzaDetails()),
                    Expanded(flex: 2, child: _PizzaIngredient())
                  ],
                ),
              )),
          Positioned(
              bottom: 25,
              height: _buttonSize,
              width: _buttonSize,
              left: MediaQuery.of(context).size.width / 2 - _buttonSize / 2,
              child: _Button())
        ],
      ),
    );
  }
}

class _PizzaDetails extends StatefulWidget {
  @override
  __PizzaDetailsState createState() => __PizzaDetailsState();
}

class __PizzaDetailsState extends State<_PizzaDetails>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  BoxConstraints _pizzaConstraints;

  final _listIngredients = <Ingredient>[];
  double _total = 15;
  final _notifierFocus = ValueNotifier(false);
  List<Animation> _animationList = <Animation>[];

  Widget _buildIngredientWidget() {
    List<Widget> elements = [];
    if (_animationList.isNotEmpty) {
      for (int i = 0; i < _listIngredients.length; i++) {
        Ingredient ingredient = _listIngredients[i];
        final ingredienWidget = Image.asset(
          ingredient.image,
          height: 40,
        );
        for (int j = 0; j < ingredient.positions.length; j++) {
          final animation = _animationList[j];
          final postion = ingredient.positions[j];
          final postionX = postion.dx;
          final postionY = postion.dy;

          if (i == _listIngredients.length - 1) {
            double fromX = 0.0, fromY = 0.0;
            if (j < 1) {
              fromX = -_pizzaConstraints.maxWidth * (1 - animation.value);
            } else if (j < 2) {
              fromX = _pizzaConstraints.maxWidth * (1 - animation.value);
            } else if (j < 4) {
              fromY = -_pizzaConstraints.maxHeight * (1 - animation.value);
            } else {
              fromY = _pizzaConstraints.maxHeight * (1 - animation.value);
            }
            if (animation.value > 0) {
              elements.add(Transform(
                transform: Matrix4.identity()
                  ..translate(
                    fromX + _pizzaConstraints.maxWidth * postionX,
                    fromY + _pizzaConstraints.maxHeight * postionY,
                  ),
                child: ingredienWidget,
              ));
            } else {
              elements.add(Transform(
                  transform: Matrix4.identity()
                    ..translate(_pizzaConstraints.maxWidth * postionX,
                        _pizzaConstraints.maxHeight * postionY),
                  child: ingredienWidget));
            }
          }
        }
      }
      return Stack(
        children: elements,
      );
    }
    return SizedBox.fromSize();
  }

  void _builIngredientanimation() {
    _animationList.clear();
    _animationList.add(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.decelerate)));
    _animationList.add(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.8, curve: Curves.decelerate)));
    _animationList.add(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: Curves.decelerate)));
    _animationList.add(CurvedAnimation(
        parent: _animationController,
        curve: Interval(1.0, 0.7, curve: Curves.decelerate)));
    _animationList.add(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.decelerate)));
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(microseconds: 900));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
                child: DragTarget<Ingredient>(onAccept: (ingredient) {
              _notifierFocus.value = false;
              setState(() {
                _listIngredients.add(ingredient);
                _total++;
              });
              _builIngredientanimation();
              _animationController.forward(from: 0.0);
              print('accepted');
            }, onWillAccept: (ingredient) {
              _notifierFocus.value = true;
              for (Ingredient i in _listIngredients) {
                if (i.compare(ingredient)) {
                  return false;
                }
              }

              return true;
            }, onLeave: (ingredient) {
              print('leave');

              _notifierFocus.value = false;
            }, builder: (context, list, rejects) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  _pizzaConstraints = constraints;
                  return Center(
                      child: ValueListenableBuilder<bool>(
                          valueListenable: _notifierFocus,
                          builder: (context, value, _) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              height: value
                                  ? constraints.maxHeight
                                  : constraints.maxHeight - 20,
                              child: Stack(
                                children: [
                                  Image.asset('assets/dish.png'),
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Image.asset('assets/pizza-1.png'),
                                  )
                                ],
                              ),
                            );
                          }));
                },
              );
            })),
            const SizedBox(height: 5),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(Tween<Offset>(
                        begin: Offset(0.0, 0.0),
                        end: Offset(0.0, animation.value))),
                    child: child,
                  ),
                );
              },
              child: Text(
                "$_total DT",
                key: UniqueKey(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            )
          ],
        ),
        AnimatedBuilder(
            animation: _animationController,
            builder: (contex, _) {
              return _buildIngredientWidget();
            }),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow,
                Colors.orange,
              ])),
      child: Icon(
        Icons.shopping_cart_outlined,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _PizzaIngredient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _PizzaIngredientItem(
          ingredient: ingredient,
        );
      },
    );
  }
}

class _PizzaIngredientItem extends StatelessWidget {
  const _PizzaIngredientItem({Key key, this.ingredient}) : super(key: key);
  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
        padding: EdgeInsets.symmetric(horizontal: 7),
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.15),
              shape: BoxShape.circle),
          child: Image.asset(
            ingredient.image,
            fit: BoxFit.contain,
          ),
        ));
    return Draggable(
      feedback: child,
      data: ingredient,
      child: child,
    );
  }
}
