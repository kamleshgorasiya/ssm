/**
 * Model class for displaying cart data to user
 * 
 * Properties :-
 * 
 * @item_id:number;
 * @name:string;
 * @price:number;
 * @discounted_price:number;
 * @actual_price:number;
 * @actual_discount:number;
 * @quantity:number;
 * @size:string;
 * @color:string;
 * @image:string;
 * @attributes:string;
 */


export class CartProduct {
    item_id:number;
    name:string;
    price:number;
    discounted_price:number;
    actual_price:number;
    actual_discount:number;
    quantity:number;
    size:string;
    color:string;
    image:string;
    attributes:string;
}

