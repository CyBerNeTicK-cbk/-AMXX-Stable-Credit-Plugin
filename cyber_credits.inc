#if defined _cyber_credits_included
	#endinput
#endif
#define _cyber_credits_included

native get_user_credits(client);
native set_user_credits(client, ammount);

stock give_credits(client, ammount)
{
	return set_user_credits(client, get_user_credits(client) + ammount);
}
stock delete_credits(client, ammount)
{
	return set_user_credits(client, get_user_credits(client) - ammount);
}

